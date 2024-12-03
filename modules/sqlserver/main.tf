resource "random_string" "name" {
  length  = 8
  lower   = true
  numeric = false
  special = false
  upper   = false
}

data "azurerm_virtual_network" "vnet" {
    name = var.vnet_name
    resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "name" {
  name = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name = var.resource_group_name
}
# Enables you to manage Private DNS zones within Azure DNS
resource "azurerm_private_dns_zone" "default" {
  name                = "${random_string.name.result}.mysql.database.azure.com"
  resource_group_name = var.resource_group_name
}

# Enables you to manage Private DNS zone Virtual Network Links
resource "azurerm_private_dns_zone_virtual_network_link" "default" {
  name                  = "mysqlfsVnetZone${random_string.name.result}.com"
  private_dns_zone_name = azurerm_private_dns_zone.default.name
  resource_group_name   = var.resource_group_name
  virtual_network_id    = data.azurerm_virtual_network.vnet.id
}

# Manages the MySQL Flexible Server
resource "azurerm_mysql_flexible_server" "default" {
  location                     = "Norwayeast"
  name                         = "mysqlfs-${random_string.name.result}"
  resource_group_name          = var.resource_group_name
  administrator_login          = "sqladmin"
  administrator_password       = "SqLaDmin123"
  backup_retention_days        = 7
  delegated_subnet_id          = data.azurerm_subnet.name.id
  geo_redundant_backup_enabled = false
  private_dns_zone_id          = azurerm_private_dns_zone.default.id
  sku_name                     = "GP_Standard_D2ds_v4"
  version                      = "8.0.21"

  high_availability {
    mode                      = "SameZone"
  }
  maintenance_window {
    day_of_week  = 0
    start_hour   = 8
    start_minute = 0
  }
  storage {
    iops    = 360
    size_gb = 20
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.default]
}

resource "azurerm_mysql_flexible_database" "Flexibledb" {
  name                = "flexidb"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.default.name
  charset             = "utf8"
  collation           = "utf8_general_ci"
}
