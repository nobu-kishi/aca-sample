resource "azurerm_resource_group" "common" {
  name     = format("%s-common-rg", var.env)
  location = var.location
}

module "infra" {
  source               = "./modules/infra"
  resource_group_name  = azurerm_resource_group.common.name
  env                  = var.env
  location             = var.location
  subnet_cidr_map      = var.subnet_cidr_map
  vnet_address_space   = var.vnet_address_space
  storage_account_name = var.storage_account_name
  vm_config            = var.vm_config
}

module "app" {
  source             = "./modules/app"
  location           = var.location
  env                = var.env
  vnet_id            = module.infra.vnet_id
  aca_subnet_id      = module.infra.aca_subnet_id
  pe_subnet_id       = module.infra.pe_aca_env_subnet_id
  acr_name           = var.acr_name
  aca_env_name       = var.aca_env_name
  container_apps     = var.container_apps
  storage_share_name = module.infra.storage_share_name
}

module "app_routing" {
  source              = "./modules/app_routing"
  resource_group_name = azurerm_resource_group.common.name
  location            = var.location
  env                 = var.env
  appgw_subnet_id     = module.infra.appgw_subnet_id
  aca_apps            = module.app.aca_apps
  backend_services    = var.backend_services
  app_gateway_name    = var.app_gateway_name
  appgw_private_ip    = var.appgw_private_ip
}