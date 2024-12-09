# Data source to retrieve the Key Vault
data "azurerm_key_vault" "bqakv" {
  name                = "bqakvtest"               # Replace with your Key Vault name
  resource_group_name = "azuremvpstack-akv"       # Replace with your Resource Group name
}

# Data source to fetch the secret from Key Vault
data "azurerm_key_vault_secret" "db_connection_string" {
  name         = "sql-connection-string"          # Replace with your secret name
  key_vault_id = data.azurerm_key_vault.bqakv.id
}

data "azurerm_client_config" "current" {}

####################################################
#assign the adf managed identity to key vault

# Run Azure CLI Command to Set Key Vault Policy
# resource "null_resource" "assign_adf_to_keyvault" {
#   depends_on = [azurerm_data_factory.azuredfd]

#   provisioner "local-exec" {
#     command = <<EOT
#       az keyvault set-policy --name ${data.azurerm_key_vault.bqakv.name} --resource-group ${data.azurerm_key_vault.bqakv.resource_group_name} --object-id ${azurerm_data_factory.azuredfd.identity[0].principal_id} --secret-permissions get
#     EOT
#   }
# }

resource "azurerm_key_vault_access_policy" "adf_to_keyvault" {
  key_vault_id = data.azurerm_key_vault.bqakv.id
  object_id    = azurerm_data_factory.azuredfd.identity[0].principal_id
  tenant_id    = data.azurerm_client_config.current.tenant_id

  secret_permissions = [
    "Get"
  ]
}

###################################################

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
  public_network_enabled = false
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

  depends_on = [ azurerm_key_vault_access_policy.adf_to_keyvault ]
}

# Linked service for SQL Server
resource "azurerm_data_factory_linked_service_sql_server" "example" {
  name            = "sql-server-linked-service"
  data_factory_id = azurerm_data_factory.azuredfd.id

  connection_string = data.azurerm_key_vault_secret.db_connection_string.value

  depends_on = [ azurerm_key_vault_access_policy.adf_to_keyvault,azurerm_data_factory_integration_runtime_self_hosted.self_hosted_ir ]
}


# Dataset for SQL Server Table
resource "azurerm_data_factory_dataset_sql_server_table" "example" {
  name                = "example_sql_dataset"
  data_factory_id     = azurerm_data_factory.azuredfd.id
  linked_service_name = azurerm_data_factory_linked_service_sql_server.example.name
  table_name          = "table-1"  # Specify the SQL Server table name

  depends_on = [ azurerm_key_vault_access_policy.adf_to_keyvault, azurerm_data_factory_integration_runtime_self_hosted.self_hosted_ir ]
}

# Linked service for Blob Storage
resource "azurerm_data_factory_linked_service_azure_blob_storage" "example_blob" {
  name                    = "example_blob_storage_link"
  data_factory_id         = azurerm_data_factory.azuredfd.id
  use_managed_identity = true
  connection_string_insecure = data.azurerm_storage_account.adlgstg.primary_connection_string
  

  depends_on = [ azurerm_key_vault_access_policy.adf_to_keyvault ]
}

# Dataset for Blob Storage
resource "azurerm_data_factory_dataset_azure_blob" "example_blob" {
  name                    = "example_blob_dataset"
  data_factory_id         = azurerm_data_factory.azuredfd.id
  linked_service_name     = azurerm_data_factory_linked_service_azure_blob_storage.example_blob.name

  path     = "${data.azurerm_storage_container.bronze.name}"

  depends_on = [ azurerm_key_vault_access_policy.adf_to_keyvault ]
}

resource "azurerm_data_factory_trigger_schedule" "example" {
  name            = "Pipeline-timer"
  data_factory_id = azurerm_data_factory.azuredfd.id
  pipeline_name   = azurerm_data_factory_pipeline.adfpipeline.name

  interval  = 5
  frequency = "Day"
}


#RBAC
resource "azurerm_role_assignment" "stgrbac" {
  principal_id         = azurerm_data_factory.azuredfd.identity[0].principal_id
  role_definition_name = "Storage Blob Data Contributor" # Role to assign
  scope                = data.azurerm_storage_account.adlgstg.id

  depends_on = [ data.azurerm_storage_account.adlgstg ]
}





