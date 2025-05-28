resource "azurerm_resource_group" "app" {
  name     = format("%s-aca-rg", var.env)
  location = var.location
}

resource "azurerm_log_analytics_workspace" "app" {
  name                = format("%s-%s", var.env, "logs")
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# NOTE: ECRは1リソース=1リポジトリだが、ACRは1リソース=複数のリポジトリを持つことができる
# https://learn.microsoft.com/ja-jp/azure/container-registry/container-registry-overview
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.app.name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = false
}

resource "azurerm_container_app_environment" "aca_env" {
  name                       = var.aca_env_name
  location                   = var.location
  resource_group_name        = azurerm_resource_group.app.name
  infrastructure_subnet_id   = var.aca_subnet_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.app.id

  # NOTE: 1つの環境に対して、最大5つのワークロードプロファイルを作成できる
  # https://learn.microsoft.com/ja-jp/azure/container-apps/environment-workload-profiles
  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
  }

  # NOTE: プライベートエンドポイントを利用するため、内部lbは使用しない
  internal_load_balancer_enabled = false
  zone_redundancy_enabled        = true


  lifecycle {
    ignore_changes = [
      # NOTE: Azure管理の「ME」〜というリソースグループが自動作成され、planで差分検知されるので一旦無視する
      infrastructure_resource_group_name
    ]
  }
}

# NOTE: ACAのパブリックIPを無効化は、preview版の機能のため、azapi_resource_actionを使用する
# https://learn.microsoft.com/ja-jp/azure/container-apps/how-to-use-private-endpoint?pivots=azure-cli#create-an-environment
# https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource_action
resource "azapi_resource_action" "disable_env_public_ip" {
  type        = "Microsoft.App/managedEnvironments@2024-10-02-preview"
  resource_id = azurerm_container_app_environment.aca_env.id
  method      = "PATCH"

  body = {
    properties = {
      publicNetworkAccess = "Disabled"
    }
  }

  depends_on = [azurerm_container_app_environment.aca_env]
}

# NOTE: スケールルールは、「azure_queue_scale_rule,custom_scale_rule,http_scale_rule,tcp_scale_rule」から選択
resource "azurerm_container_app" "aca_apps" {
  for_each                     = var.container_apps
  name                         = "${each.key}-app"
  container_app_environment_id = azurerm_container_app_environment.aca_env.id
  resource_group_name          = azurerm_resource_group.app.name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aca_identity.id]
  }

  registry {
    server   = azurerm_container_registry.acr.login_server
    identity = azurerm_user_assigned_identity.aca_identity.id
  }

  ingress {
    external_enabled = true
    target_port      = each.value.port
    transport        = "auto"
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  template {
    container {
      name   = each.key
      image  = "${azurerm_container_registry.acr.login_server}/${each.value.image}"
      cpu    = each.value.cpu
      memory = each.value.memory

      volume_mounts {
        name = "sharedvol"
        path = "/mnt/shared"
      }
    }
    
    min_replicas = 0 # 0を設定することで、リクストがない時は停止できる（常駐させる場合は、1を設定）
    max_replicas = 1

    volume {
      name         = "sharedvol"
      storage_name = var.storage_share_name
      storage_type = "AzureFile"
    }
  }

  lifecycle {
    ignore_changes = [
      # NOTE: Consumptionプランを使用する場合、terraform実行時にプロファイル設定をnullで置換するため、無視する
      workload_profile, 
      # NOTE: ACAの環境を変更すると、azurerm_container_appのrevision_modeが変更されるため、無視する
      revision_mode,
      # NOTE: ACAの環境を変更すると、azurerm_container_appのingressが変更されるため、無視する
      ingress,
    ]
  }
}

resource "azurerm_user_assigned_identity" "aca_identity" {
  name                = "aca-identity"
  location            = var.location
  resource_group_name = azurerm_resource_group.app.name
}

resource "azurerm_role_assignment" "acr_pull" {
  principal_id         = azurerm_user_assigned_identity.aca_identity.principal_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
}

resource "azurerm_private_endpoint" "aca_private_endpoint" {
  name                = "aca-private-endpoint"
  location            = var.location
  resource_group_name = azurerm_resource_group.app.name
  subnet_id           = var.pe_subnet_id

  private_service_connection {
    name                           = "aca-private-connection"
    private_connection_resource_id = azurerm_container_app_environment.aca_env.id
    subresource_names              = ["managedEnvironments"]
    is_manual_connection           = false
  }
}

# https://learn.microsoft.com/ja-jp/azure/private-link/private-endpoint-dns#containers
resource "azurerm_private_dns_zone" "aca_private_dns" {
  name                = format("privatelink.%s.azurecontainerapps.io", var.location)
  resource_group_name = azurerm_resource_group.app.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "aca_dns_vnet_link" {
  name                  = "aca-dns-link"
  resource_group_name   = azurerm_resource_group.app.name
  private_dns_zone_name = azurerm_private_dns_zone.aca_private_dns.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
}

resource "azurerm_private_dns_a_record" "main" {
  # NOTE: <name>.<location>.azurecontainerapps.ioから、<name>の部分を取得する
  name                = split(".", azurerm_container_app_environment.aca_env.default_domain)[0]
  zone_name           = azurerm_private_dns_zone.aca_private_dns.name
  resource_group_name = azurerm_resource_group.app.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.aca_private_endpoint.private_service_connection[0].private_ip_address]
}
