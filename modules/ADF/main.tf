module "locals" {
  source = "../local"
}

# Azure Client Configuration
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "azakv" {
  name                        = var.local_key_vault_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id  # Adjust to your needs
    secret_permissions = ["Get", "List", "Set", "Delete"]
  }
}

# Key Vault Secret for SQL Server Connection String
resource "azurerm_key_vault_secret" "sql_connection_string" {
  name         = "sql-server-connection-string"
  value        = <<EOT
    Server=AIP10193LT19664\SQLEXPRESS;
    Database=EXAMPLEDB;
    TrustServerCertificate=False;
    User Id=sa;
    Password=Password@1110;
  EOT

  key_vault_id = azurerm_key_vault.azakv.id

  depends_on = [ azurerm_key_vault.azakv ]
}


###################################################3

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_storage_account" "adlgstg" {
  name = var.adlgstg_name
  resource_group_name = var.resource_group_name
}

data "azurerm_storage_container" "bronze" {
  name = "bronze"
  storage_account_name = data.azurerm_storage_account.adlgstg.name
}



resource "random_string" "stg" {
  length  = 3
  special = false
  upper   = false
  lower   = true
  numeric = true
}

# Create Azure data factory with storage account and containers
resource "azurerm_data_factory" "azuredfd" {
  name                = var.datafactory_name  // update the name
  location            = var.location
  resource_group_name = var.resource_group_name
  public_network_enabled = true
  managed_virtual_network_enabled = true

  identity {
    type = "SystemAssigned" # Enable system-assigned managed identity
  }
}

resource "azurerm_data_factory_integration_runtime_self_hosted" "self_hosted_ir" {
  name            = "exampleSelfHostedIR"
  data_factory_id = azurerm_data_factory.azuredfd.id
}

# Data Factory Pipeline with Copy Activity
resource "azurerm_data_factory_pipeline" "adfpipeline" {
  name            = "example-pipeline"
  data_factory_id = azurerm_data_factory.azuredfd.id

  activities_json = <<-JSON
  [
    {
      "name": "CopyFromSQLtoBlob",
      "type": "Copy",
      "dependsOn": [],
      "userProperties": [],
      "typeProperties": {
        "source": {
          "type": "SqlSource"
        },
        "sink": {
          "type": "BlobSink"
        }
      },
      "inputs": [
        {
          "referenceName": "${azurerm_data_factory_dataset_sql_server_table.example.name}",
          "type": "DatasetReference"
        }
      ],
      "outputs": [
        {
          "referenceName": "${azurerm_data_factory_dataset_azure_blob.example_blob.name}",
          "type": "DatasetReference"
        }
      ]
    }
  ]
  JSON
}

# Linked service for SQL Server
resource "azurerm_data_factory_linked_service_sql_server" "example" {
  name            = "SqlServerLinkedService"
  data_factory_id = azurerm_data_factory.azuredfd.id

  connection_string = azurerm_key_vault_secret.sql_connection_string.value
}


# Dataset for SQL Server Table
resource "azurerm_data_factory_dataset_sql_server_table" "example" {
  name                = "example-sql-dataset"
  data_factory_id     = azurerm_data_factory.azuredfd.id
  linked_service_name = azurerm_data_factory_linked_service_sql_server.example.name
  table_name          = "EXAMPLEDB"  # Specify the SQL Server table name
}

# Linked service for Blob Storage
resource "azurerm_data_factory_linked_service_azure_blob_storage" "example_blob" {
  name                    = "example-blob-storage-link"
  data_factory_id         = azurerm_data_factory.azuredfd.id
  use_managed_identity = true
  connection_string_insecure = data.azurerm_storage_account.adlgstg.primary_connection_string
}

# Dataset for Blob Storage
resource "azurerm_data_factory_dataset_azure_blob" "example_blob" {
  name                    = "example-blob-dataset"
  data_factory_id         = azurerm_data_factory.azuredfd.id
  linked_service_name     = azurerm_data_factory_linked_service_azure_blob_storage.example_blob.name

  path     = "${data.azurerm_storage_container.bronze.name}"
}




#RBAC
resource "azurerm_role_assignment" "stgrbac" {
  principal_id         = azurerm_data_factory.azuredfd.identity[0].principal_id
  role_definition_name = "Storage Blob Data Contributor" # Role to assign
  scope                = data.azurerm_storage_account.adlgstg.id

  depends_on = [ data.azurerm_storage_account.adlgstg ]
}


resource "random_string" "this" {
  length  = 4
  special = false
  upper   = false
  lower   = true
  numeric = true
}

resource "azurerm_storage_account" "sourcestorage" {
  name                     = format("${var.company}${var.env}${random_string.this.result}sou")  //update the storage account name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_storage_account" "destinationstorage" {
  name                     = format("adf${var.company}${var.env}${random_string.this.result}des")  //update the storage accountname
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_storage_container" "containersource" {
  name                  = "coursecontainer" 
  storage_account_name  = azurerm_storage_account.sourcestorage.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "containerdestination" {
  name                  = "destinationcontainer" 
  storage_account_name  = azurerm_storage_account.destinationstorage.name
  container_access_type = "private"
}






