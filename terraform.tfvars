env                = "dev"
subscription_id    = "b17158f1-9101-4ce3-9224-19e1561bbd4b"
location           = "japaneast"
vnet_address_space = ["10.0.0.0/16"]
subnet_cidr_map = {
  bastion    = "10.0.0.0/27"
  vm         = "10.0.10.0/24"
  postgresql = "10.0.20.0/24"
  aca        = "10.0.100.0/24"
}
acr_name         = "acaregistry20250423"
aca_env_name     = "aca-env"
aca_profile_name = "aca-profile"
app_gateway_name = "aca-appgw"

container_apps = {
  frontend = {
    image  = "frontend:latest"
    cpu    = 0.5
    memory = "1Gi"
    port   = 8081
  },
  backend = {
    image  = "backend:latest"
    cpu    = 0.5
    memory = "1Gi"
    port   = 8082
  }
}

backend_services = {
  frontend = {
    # fqdn = "frontend.containers.azure.com"
    port = 80
    name = "frontend"
  },
  backend = {
    # fqdn = "backend.containers.azure.com"
    port = 3000
    name = "frontend" # 
  },
}
