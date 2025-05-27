locals {
  subnet_name_fmt        = "%s-%s-subnet"
  vnet_name              = format("%s-vnet", var.env)
  vm_subnet_name         = format("%s-vm-subnet", var.env)
  aca_subnet_name        = format("%s-aca-subnet", var.env)
  pe_subnet_name         = format("%s-pe-aca-subnet", var.env)
  appgw_subnet_name      = format("%s-appgw-subnet", var.env)
  postgresql_subnet_name = format("%s-postgresql-subnet", var.env)
  postgresql_server_name = format("%s-pg-flexibleserver", var.env)
  storage_share_name     = format("%s-shared-storage", var.env)
}
