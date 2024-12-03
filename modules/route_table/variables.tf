variable "resource_group_name" {
  description = "The name of the Resource Group"
  type        = string
}

variable "location" {
  description = "The Azure region in which to create the resources"
  type        = string
}

variable "route_table_name" {
  description = "The name of the Route Table"
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to the Route Table"
  type        = map(string)
  default     = {}
}
