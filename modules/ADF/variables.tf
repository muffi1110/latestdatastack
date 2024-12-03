variable "resource_group_name" {
  description = "The name of the Resource Group"
  type        = string
}

variable "location" {
  description = "The Azure region in which to create the resources"
  type        = string
}

variable "company" {
  description = "Update the company name"
  default = "bq"
}

variable "env" {
  description = "Environment name"
  default = "stg"
}

variable "vnet_name" {
  description = "The name of the Virtual Network"
  type        = string
}

variable "private_subnet_az1" {
  description = "The name of the Subnet"
  type        = string
}

variable "datafactory_name" {
  description = "The name of the data factory"
  type = string
}

variable "adlgstg_name" {
  description = "adf stg name"
}

variable "local_key_vault_name" {
  description = "local key vault name"
}

# variable "sql_connection_string" {
#   type = string
# }

