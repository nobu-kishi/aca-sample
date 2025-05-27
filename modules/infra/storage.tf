resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "shared" {
  name               = local.storage_share_name
  storage_account_id = azurerm_storage_account.storage.id
  quota              = 5 # 5GB
}