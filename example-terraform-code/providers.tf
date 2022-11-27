terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
  backend "azurerm"{
        resource_group_name   = "[VALUE]"
        storage_account_name  = "[VALUE]"
        container_name        = "[VALUE]"
        key                   = "[VALUE]"
    }
}

provider "azurerm" {
  features {}
  subscription_id = "[VALUE]"
}
