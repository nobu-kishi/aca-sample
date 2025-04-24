# NOTE: バックエンド用コンテナもリクエストを受けられるようにしているが、紐付けできるコンテナ数が100までなので不要であれば削除する
# https://learn.microsoft.com/ja-jp/azure/azure-resource-manager/management/azure-subscription-service-limits#azure-application-gateway-limits

# NOTE: backend系の定義に変更（追加・削除・順序変更）を加えると、planで差分検知されるが実際は再作成されない（詳細は、下記参照）
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway
resource "azurerm_application_gateway" "appgw" {
  name                = var.app_gateway_name
  location            = var.location
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                          = "appgw-fe-ip"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = var.subnet_id
  }

  # NOTE: リスナーポートに相当する
  # NOTE: Application Gatewayのリスナーは、HTTP/HTTPSのプロトコルを指定する必要がある
  dynamic "frontend_port" {
    for_each = var.backend_services
    content {
      name = "port-${frontend_port.value.port}"
      port = frontend_port.value.port
    }
  }

  # NOTE: リスナーに相当する
  dynamic "http_listener" {
    for_each = var.backend_services
    content {
      name                           = "${http_listener.value.name}-listener"
      frontend_ip_configuration_name = "appgw-fe-ip"
      frontend_port_name             = "port-${http_listener.value.port}"
      protocol                       = "Http"
    }
  }

  # NOTE: ターゲットグループに相当する
  # NOTE: Application Gatewayのバックエンドプールは、IPアドレスまたはFQDNを指定する必要がある
  dynamic "backend_address_pool" {
    for_each = var.backend_services
    content {
      name  = "${backend_address_pool.value.name}-backend-pool"
      fqdns = [var.aca_apps[backend_address_pool.value.name].latest_revision_fqdn]
    }
  }

  # NOTE: ターゲットグループに相当する
  dynamic "backend_http_settings" {
    for_each = var.backend_services
    content {
      name                  = "${backend_http_settings.value.name}-http-settings"
      cookie_based_affinity = backend_http_settings.key == "frontend" ? "Enabled" : "Disabled"
      port                  = backend_http_settings.value.port
      protocol              = "Http"
      request_timeout       = 30
    }
  }

  # NOTE: リスナールールに相当する
  dynamic "request_routing_rule" {
    for_each = var.backend_services
    content {
      name                       = "${request_routing_rule.value.name}-rule"
      rule_type                  = "Basic"
      http_listener_name         = "${request_routing_rule.value.name}-listener"
      backend_address_pool_name  = "${request_routing_rule.value.name}-backend-pool"
      backend_http_settings_name = "${request_routing_rule.value.name}-http-settings"
    }
  }

  # NOTE: 原則、削除しない運用を想定
  # lifecycle {
  #   prevent_destroy = true
  # }
}