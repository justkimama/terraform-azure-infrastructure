terraform {
  required_version = "1.8.2"
  backend "azurerm" {
    resource_group_name = "tmp"
    # Storage Account created on Azure Portal
    storage_account_name = "tmp"
    container_name       = "tfstate"
    key                  = "root.terraform.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.80.0"
    }
  }
}

provider "azurerm" {
  features {}
}
