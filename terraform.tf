provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = var.subscription_id
}

provider "azapi" {
}

terraform {
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "2.4.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.26.0"
    }
  }
}