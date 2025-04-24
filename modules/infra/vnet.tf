resource "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  address_space       = var.vnet_address_space
  location            = var.location
  resource_group_name = var.resource_group_name
}

# NOTE: AWSのサブネットと違い、単一のAZに依存しない論理的グループであるため、AZを指定する必要はない
# https://learn.microsoft.com/ja-jp/azure/virtual-network/virtual-networks-overview#virtual-networks-and-availability-zones
resource "azurerm_subnet" "bastion_subnet" {
  # NOTE: Azure Bastion用のサブネット名は固定
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_cidr_map["bastion"]]
}

resource "azurerm_subnet" "vm_subnet" {
  name                 = local.vm_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_cidr_map["vm"]]
}

resource "azurerm_subnet" "aca_subnet" {
  name                 = local.aca_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_cidr_map["aca"]]
  delegation {
    name = "delegation"
    service_delegation {
      name    = "Microsoft.App/environments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet" "postgresql_subnet" {
  name                 = local.postgresql_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_cidr_map["postgresql"]]
  delegation {
    name = "delegation"
    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}
