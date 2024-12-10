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
####################################################
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

###################################################

#Azure file share linked service

resource "azurerm_storage_account" "stgafs" {
  name                     = format("azurefileshare${random_string.this.result}")
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "AzurefileShare" {
  name                 = "demofileshare"
  storage_account_name = azurerm_storage_account.stgafs.name
}

####################################################

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

  depends_on = [ azurerm_key_vault_access_policy.adf_to_keyvault ]
}

# Data Factory Pipeline with Copy Activity
resource "azurerm_data_factory_pipeline" "adfpipeline" {
  name            = "example-pipeline"
  data_factory_id = azurerm_data_factory.azuredfd.id

  activities_json = <<-JSON
  [
    {
      "name": "CopyFromFileShareToBlob",
      "type": "Copy",
      "dependsOn": [],
      "userProperties": [],
      "typeProperties": {
        "source": {
          "type": "FileSystemSource"
        },
        "sink": {
          "type": "BlobSink"
        }
      },
      "inputs": [
        {
          "referenceName": "${azurerm_data_factory_dataset_file.example_file_dataset.name}",
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

  depends_on = [ azurerm_key_vault_access_policy.adf_to_keyvault, azurerm_storage_account.stgafs ]
}


resource "azurerm_data_factory_linked_service" "file_share" {
  name                = "example-file-share-link"
  resource_group_name = var.resource_group_name
  data_factory_name   = azurerm_data_factory.azuredfd.id

  type = "AzureFileStorage"

  type_properties_json = jsonencode({
    connectionString = "DefaultEndpointsProtocol=https;AccountName=${azurerm_storage_account.stgafs.name};AccountKey=${azurerm_storage_account.stgafs.primary_access_key}"
  })

  depends_on = [ azurerm_key_vault_access_policy.adf_to_keyvault, azurerm_storage_account.stgafs ]
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





