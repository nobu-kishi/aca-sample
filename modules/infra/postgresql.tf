resource "azurerm_postgresql_flexible_server" "postgresql" {
  name                          = local.postgresql_server_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  administrator_login           = var.postgresql_admin_user
  administrator_password        = var.postgresql_admin_password
  version                       = "13"
  storage_mb                    = 32768
  sku_name                      = "B_Standard_B1ms"
  zone                          = "1" # 任意のAZ指定（フレシキブルサーバーの場合必須）
  delegated_subnet_id           = azurerm_subnet.postgresql_subnet.id
  public_network_access_enabled = false
  private_dns_zone_id           = azurerm_private_dns_zone.postgresql_private_dns.id

  depends_on = [azurerm_private_dns_zone_virtual_network_link.postgresql_dns_link]
}

# プライベートエンドポイント経由でpostgresqlに接続できるようにする
# https://learn.microsoft.com/ja-jp/azure/postgresql/flexible-server/concepts-networking-private-link
resource "azurerm_private_dns_zone" "postgresql_private_dns" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgresql_dns_link" {
  name                  = "${local.postgresql_server_name}-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.postgresql_private_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

