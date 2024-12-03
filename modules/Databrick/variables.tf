variable "resource_group_name" {
  description = "The name of the Resource Group"
  type        = string
}

variable "location" {
  description = "The Azure region in which to create the resources"
  type        = string
}

variable "env" {
  type    = string
  default = "stg"
}

variable "dbwscope" {
  type    = string
  default = "azkvdbwscopedev" // update the value
}

variable "stgaccname" {
  type    = string
  default = "stg" // update the value
}


# Change the default value for a unique name
variable "company" {
  default = "bq"
  type = string
}


variable "secretsname" {
    type = map
    default = {
        "databricksappsecret" = "databricksappsecret"
        "databricksappclientid" = "databricksappclientid"
        "tenantid" = "tenantid"
    }
}