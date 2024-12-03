resource "random_string" "this" {
  length  = 4
  special = false
  upper   = false
  lower   = true
}

resource "azurerm_storage_account" "adlgstg" {
  name = var.adlgstg_name
  resource_group_name = var.resource_group_name
  location = var.location
  account_tier = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "azdlgfs" {
  name = format("${var.stg}${var.env}${random_string.this.result}")
   storage_account_id = azurerm_storage_account.adlgstg.id
}

resource "azurerm_storage_container" "bronze" {
  name                  = "bronze"
  storage_account_name = azurerm_storage_account.adlgstg.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "silver" {
  name                  = "silver"
  storage_account_name    = azurerm_storage_account.adlgstg.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "gold" {
  name                  = "gold"
  storage_account_name  = azurerm_storage_account.adlgstg.name
  container_access_type = "private"
}



