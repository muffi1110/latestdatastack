terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.72.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "1.27.0"
    }
    azuread = {
      source = "hashicorp/azuread"
      version = "2.43.0"
    }
    time = {
      source = "hashicorp/time"
      version = "0.9.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
  subscription_id = "621067e5-185b-4ba3-9183-39e19dbfb89a" //update your subscription id
  tenant_id = "d47f518f-b7ff-46c4-80ea-89c1c3139271"
  client_id = "87b9d962-d1a4-4d0f-9950-52a419ab0d3e"
  client_secret = "o_38Q~DNFiLCQcbUicBSjfgX4bczhnngS7bmja1O"
}

provider "azuread" {
  # Configuration options
}

provider "time" {
  # Configuration options
}

provider "databricks" {
  host = azurerm_databricks_workspace.dbwdata01.workspace_url
  azure_workspace_resource_id = azurerm_databricks_workspace.dbwdata01.id
}

