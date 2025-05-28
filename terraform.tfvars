env                = "dev"
subscription_id    = "b17158f1-9101-4ce3-9224-19e1561bbd4b"
location           = "japaneast"
vnet_address_space = ["10.0.0.0/16"]
subnet_cidr_map = {
  bastion    = "10.0.0.0/27"
  vm         = "10.0.10.0/24"
  postgresql = "10.0.20.0/24"
  appgw      = "10.0.30.0/24"
  aca        = "10.0.100.0/24"
  pe_aca_env = "10.0.101.0/28"
}

acr_name             = "acaregistry20250423"
aca_env_name         = "aca-env"
aca_profile_name     = "aca-profile"
app_gateway_name     = "aca-appgw"
appgw_private_ip     = "10.0.30.10"
storage_account_name = "storage20250423"

vm_config = {
  linux = [
    {
      name = "linux-vm-01"
    }
  ],
  windows = [
    {
      name = "windows-vm-01"
    }
  ]
}

container_apps = {
  frontend = {
    image  = "frontend:latest"
    cpu    = 0.5
    memory = "1Gi"
    port   = 3000
  },
  backend = {
    image  = "backend:latest"
    cpu    = 0.5
    memory = "1Gi"
    port   = 8080
  }
}

backend_services = {
  frontend = {
    name          = "frontend"
    frontend_port = 80
    backend_port  = 3000
    fqdn          = "frontend.containers.azure.com"
    priority      = 100
  },
  backend = {
    fqdn          = "backend.containers.azure.com"
    frontend_port = 80
    backend_port  = 8080
    name          = "backend"
    priority      = 110
  },
}
