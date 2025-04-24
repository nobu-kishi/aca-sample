resource "azurerm_resource_group" "common" {
  name     = format("%s-common-rg", var.env)
  location = var.location
}

module "infra" {
  source              = "./modules/infra"
  resource_group_name = azurerm_resource_group.common.name
  env                 = var.env
  location            = var.location
  subnet_cidr_map     = var.subnet_cidr_map
  vnet_address_space  = var.vnet_address_space
}

module "app" {
  source         = "./modules/app"
  location       = var.location
  env            = var.env
  subnet_id      = module.infra.aca_subnet_id
  acr_name       = var.acr_name
  aca_env_name   = var.aca_env_name
  container_apps = var.container_apps
}

module "app_routing" {
  source              = "./modules/app_routing"
  resource_group_name = azurerm_resource_group.common.name
  location            = var.location
  env                 = var.env
  subnet_id           = module.infra.aca_subnet_id
  app_gateway_name    = var.app_gateway_name
  backend_services    = var.backend_services
  aca_apps            = module.app.aca_apps
}
# resource "azurerm_virtual_network" "vnet" {
#   name                = var.vnet_name
#   address_space       = var.vnet_address_space
#   location            = var.location
#   resource_group_name = azurerm_resource_group.rg.name
# }

# # NOTE: AWSのサブネットと違い、単一のAZに依存しない論理的グループであるため、AZを指定する必要はない
# # https://learn.microsoft.com/ja-jp/azure/virtual-network/virtual-networks-overview#virtual-networks-and-availability-zones
# resource "azurerm_subnet" "aca_subnet" {
#   name                 = var.subnet_name
#   resource_group_name  = azurerm_resource_group.rg.name
#   virtual_network_name = azurerm_virtual_network.vnet.name
#   address_prefixes     = var.subnet_address_prefixes
#   delegation {
#     name = "delegation"
#     service_delegation {
#       name    = "Microsoft.App/environments"
#       actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
#     }
#   }
# }

# resource "azurerm_container_app_environment" "aca_env" {
#   name                     = var.aca_env_name
#   location                 = var.location
#   resource_group_name      = azurerm_resource_group.rg.name
#   infrastructure_subnet_id = azurerm_subnet.aca_subnet.id
#   workload_profile {
#     name                  = "Consumption"
#     workload_profile_type = "Consumption"
#     # NOTE: 1つの環境に対して、最大5つのワークロードプロファイルを作成できる
#     # https://learn.microsoft.com/ja-jp/azure/container-apps/environment-workload-profiles
#     maximum_count = 5
#     minimum_count = 0
#   }
#   internal_load_balancer_enabled = true
#   zone_redundancy_enabled        = true
# }

# # NOTE: ECRは1リソース=1リポジトリだが、ACRは1リソース=複数のリポジトリを持つことができる
# # https://learn.microsoft.com/ja-jp/azure/container-registry/container-registry-overview
# resource "azurerm_container_registry" "acr" {
#   name                = var.acr_name
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = var.location
#   sku                 = "Basic"
#   admin_enabled       = true
# }

# resource "azurerm_container_app" "aca_apps" {
#   for_each                     = var.container_apps
#   name                         = "${each.key}-app"
#   container_app_environment_id = azurerm_container_app_environment.aca_env.id
#   resource_group_name          = azurerm_resource_group.rg.name
#   revision_mode                = "Single"

#   identity {
#     type = "SystemAssigned"
#   }

#   template {
#     container {
#       name   = each.key
#       image  = "${azurerm_container_registry.acr.login_server}/${each.value.image}"
#       cpu    = each.value.cpu
#       memory = each.value.memory
#     }
#     min_replicas = 0 # 0を設定することで、リクストがない時は停止できる（常駐させる場合は、1を設定）
#     max_replicas = 1
#     # NOTE: スケールルールは、「azure_queue_scale_rule,custom_scale_rule,http_scale_rule,tcp_scale_rule」から選択
#   }

#   depends_on = [azurerm_role_assignment.acr_pull]
# }

# # ACA に ACR Pull 権限を付与
# resource "azurerm_role_assignment" "acr_pull" {
#   for_each = azurerm_container_app.aca_apps

#   principal_id         = each.value.identity[0].principal_id
#   role_definition_name = "AcrPull"
#   scope                = azurerm_container_registry.acr.id
# }

# # NOTE: バックエンド用コンテナもリクエストを受けられるようにしているが、紐付けできるコンテナ数が100までなので不要でれば削除する
# # https://learn.microsoft.com/ja-jp/azure/azure-resource-manager/management/azure-subscription-service-limits#azure-application-gateway-limits
# # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway
# resource "azurerm_application_gateway" "appgw" {
#   name                = var.app_gateway_name
#   location            = var.location
#   resource_group_name = azurerm_resource_group.rg.name

#   frontend_ip_configuration {
#     name      = "appgw-fe-ip"
#     subnet_id = azurerm_subnet.aca_subnet.id
#     # private_ip_address            = "10.0.1.5"
#     # NOTE: Dynamicの場合、コンテナが再デプロイされた時、古いIPアドレスが参照される恐れあり（要検証）
#     # private_ip_address_allocation = "Static"
#     private_ip_address_allocation = "Dynamic"
#   }

#   sku {
#     name     = "WAF_v2"
#     tier     = "WAF_v2"
#     capacity = 2
#   }

#   gateway_ip_configuration {
#     name      = "appgw-ip-config"
#     subnet_id = azurerm_subnet.aca_subnet.id
#   }

#   # NOTE: リスナーポートに相当する
#   # NOTE: Application Gatewayのリスナーは、HTTP/HTTPSのプロトコルを指定する必要がある
#   dynamic "frontend_port" {
#     for_each = var.backend_services
#     content {
#       name = "port-${frontend_port.value.port}"
#       port = frontend_port.value.port
#     }
#   }

#   # NOTE: リスナーに相当する
#   dynamic "http_listener" {
#     for_each = var.backend_services
#     content {
#       name                           = "${http_listener.value.name}-listener"
#       frontend_ip_configuration_name = "appgw-fe-ip"
#       frontend_port_name             = "port-${http_listener.value.port}"
#       protocol                       = "Http"
#     }
#   }

#   # NOTE: ターゲットグループに相当する
#   # NOTE: Application Gatewayのバックエンドプールは、IPアドレスまたはFQDNを指定する必要がある
#   dynamic "backend_address_pool" {
#     for_each = var.backend_services
#     content {
#       name  = "${backend_address_pool.value.name}-backend-pool"
#       fqdns = [azurerm_container_app.aca_apps[backend_address_pool.value.name].latest_revision_fqdn]
#     }
#   }

#   dynamic "backend_http_settings" {
#     for_each = var.backend_services
#     content {
#       name                  = "${backend_http_settings.value.name}-http-settings"
#       cookie_based_affinity = backend_http_settings.key == "frontend" ? "Enabled" : "Disabled"
#       port                  = 80
#       protocol              = "Http"
#       request_timeout       = 30
#     }
#   }

#   # NOTE: リスナールールに相当する
#   dynamic "request_routing_rule" {
#     for_each = var.backend_services
#     content {
#       name                       = "${request_routing_rule.value.name}-rule"
#       rule_type                  = "Basic"
#       http_listener_name         = "${request_routing_rule.value.name}-listener"
#       backend_address_pool_name  = "${request_routing_rule.value.name}-backend-pool"
#       backend_http_settings_name = "${request_routing_rule.value.name}-http-settings"
#     }
#   }
# }

