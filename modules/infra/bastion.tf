resource "azurerm_public_ip" "bastion_ip" {
  name                = "bastion-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "bastion" {
  name                = "bastion-host"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  tunneling_enabled   = true

  ip_configuration {
    name                 = "bastion-ip-config"
    subnet_id            = azurerm_subnet.bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.bastion_ip.id
  }
}

module "vms" {
  source              = "./vm"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = azurerm_subnet.vm_subnet.id
  vm_config           = var.vm_config
}