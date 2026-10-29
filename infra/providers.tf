terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-omnipos-tfstate"
    storage_account_name = "stomnipostf2026vn"
    container_name       = "tfstate"
    key                  = "omnipos-prod.tfstate"
  }
}

provider "azurerm" {
  features {}
}