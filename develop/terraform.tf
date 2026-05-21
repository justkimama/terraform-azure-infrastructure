terraform {
  required_version = "1.8.2"
  backend "azurerm" {
    resource_group_name = "tmp"
    # Storage Account created on Azure Portal
    storage_account_name = "tmp"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
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
  skip_provider_registration = true
}

data "terraform_remote_state" "root" {
  backend = "azurerm"

  config = {
    resource_group_name  = local.state_file_resource_group_name
    storage_account_name = local.state_file_storage_account_name
    container_name       = local.state_file_storage_container_name
    key                  = local.root_state_file
  }
}
