resource "random_string" "this" {
  length  = 5
  special = false
  upper   = false
  lower   = true
  numeric = true
}

locals {
  key_vault_name = format("akv${var.company}${var.env}${random_string.this.result}")
}

output "key_vault_name" {
  value = local.key_vault_name
}