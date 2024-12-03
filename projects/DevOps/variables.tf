variable "resource_group_name" {
  description = "The name of the Resource Group"
  type        = string
}

variable "location" {
  description = "The Azure region where the resources will be created"
  type        = string
}

variable "vnet_name" {
  description = "The name of the Virtual Network"
  type        = string
}

variable "pub_sqlsubnet" {
  description = "The name of the Subnet"
  type        = string
}

variable "subnet_address_prefix_sqlsubnet" {
  description = "The address prefix for the Subnet"
  type        = list(string)
}

variable "vnet_address_space" {
  description = "The address space for the Virtual Network"
  type        = list(string)
}

variable "pub_subnet_az1" {
  description = "The name of the Subnet"
  type        = string
}

variable "pub_subnet_az2" {
  description = "The name of the Subnet"
  type        = string
}

variable "pub_subnet_az3" {
  description = "The name of the Subnet"
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

variable "private_subnet_az2" {
  description = "The name of the Subnet"
  type        = string
}

variable "private_subnet_az3" {
  description = "The name of the Subnet"
  type        = string
}


variable "subnet_address_prefix_pub_az1" {
  description = "The address prefix for the Subnet"
  type        = list(string)
}

variable "subnet_address_prefix_pub_az2" {
  description = "The address prefix for the Subnet"
  type        = list(string)
}

variable "subnet_address_prefix_pub_az3" {
  description = "The address prefix for the Subnet"
  type        = list(string)
}

variable "subnet_address_prefix_private_az1" {
  description = "The address prefix for the Subnet"
  type        = list(string)
}

variable "subnet_address_prefix_private_az2" {
  description = "The address prefix for the Subnet"
  type        = list(string)
}

variable "subnet_address_prefix_private_az3" {
  description = "The address prefix for the Subnet"
  type        = list(string)
}

variable "nsg_name" {
  description = "The name of the Network Security Group"
  type        = string
}

variable "route_table_name" {
  description = "The name of the Route Table"
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to the resources"
  type        = map(string)
  default     = {}
}

variable "adlgstg_name" {
  description = "ADF Stg name"
}

# variable "sql_connection_string" {
#   type = string
# }