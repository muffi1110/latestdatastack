resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space

  tags = var.tags
}

resource "azurerm_subnet" "public-subnet-az1" {
  name                 = var.pub_subnet_az1
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_address_prefix_pub_az1
}

resource "azurerm_subnet" "public-subnet-az2" {
  name                 = var.pub_subnet_az2
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_address_prefix_pub_az2
}

resource "azurerm_subnet" "public-subnet-az3" {
  name                 = var.pub_subnet_az3
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_address_prefix_pub_az3
}

resource "azurerm_subnet" "sqlsubnet" {
  name                 = var.pub_sqlsubnet
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_address_prefix_sqlsubnet

  delegation {
    name = "fs"

    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_subnet" "private-subnet-az1" {
  name                 = var.private_subnet_az1
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_address_prefix_private_az1
}

resource "azurerm_subnet" "private-subnet-az2" {
  name                 = var.private_subnet_az2
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_address_prefix_private_az2
}

resource "azurerm_subnet" "private-subnet-az3" {
  name                 = var.private_subnet_az3
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_address_prefix_private_az3
}

