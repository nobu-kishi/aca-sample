locals {
  vnet_name              = format("%s-vnet", var.env)
  vm_subnet_name         = format("%s-vm-subnet", var.env)
  aca_subnet_name        = format("%s-aca-subnet", var.env)
  postgresql_subnet_name = format("%s-postgresql-subnet", var.env)
  postgresql_server_name = format("%s-pg-flexibleserver", var.env)
}
