data "azurerm_network_security_group" "nsg" {
  name = var.nsg_name
  resource_group_name = var.resource_group_name
}

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

# Associate the NSG with the Subnet
resource "azurerm_subnet_network_security_group_association" "pubsub1" {
  subnet_id                 = azurerm_subnet.public-subnet-az1.id
  network_security_group_id = data.azurerm_network_security_group.nsg.id
}

resource "azurerm_subnet" "public-subnet-az2" {
  name                 = var.pub_subnet_az2
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_address_prefix_pub_az2
}

# Associate the NSG with the Subnet
resource "azurerm_subnet_network_security_group_association" "pubsub2" {
  subnet_id                 = azurerm_subnet.public-subnet-az2.id
  network_security_group_id = data.azurerm_network_security_group.nsg.id
}

resource "azurerm_subnet" "public-subnet-az3" {
  name                 = var.pub_subnet_az3
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_address_prefix_pub_az3
}

# Associate the NSG with the Subnet
resource "azurerm_subnet_network_security_group_association" "pubsub3" {
  subnet_id                 = azurerm_subnet.public-subnet-az3.id
  network_security_group_id = data.azurerm_network_security_group.nsg.id
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

# Associate the NSG with the Subnet
resource "azurerm_subnet_network_security_group_association" "sqlsub" {
  subnet_id                 = azurerm_subnet.sqlsubnet.id
  network_security_group_id = data.azurerm_network_security_group.nsg.id
}

resource "azurerm_subnet" "private-subnet-az1" {
  name                 = var.private_subnet_az1
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_address_prefix_private_az1
}

# Associate the NSG with the Subnet
resource "azurerm_subnet_network_security_group_association" "prisub1" {
  subnet_id                 = azurerm_subnet.private-subnet-az1.id
  network_security_group_id = data.azurerm_network_security_group.nsg.id
}

resource "azurerm_subnet" "private-subnet-az2" {
  name                 = var.private_subnet_az2
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_address_prefix_private_az2
}

# Associate the NSG with the Subnet
resource "azurerm_subnet_network_security_group_association" "prisub2" {
  subnet_id                 = azurerm_subnet.private-subnet-az2.id
  network_security_group_id = data.azurerm_network_security_group.nsg.id
}

resource "azurerm_subnet" "private-subnet-az3" {
  name                 = var.private_subnet_az3
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_address_prefix_private_az3
}

# Associate the NSG with the Subnet
resource "azurerm_subnet_network_security_group_association" "prisub3" {
  subnet_id                 = azurerm_subnet.private-subnet-az3.id
  network_security_group_id = data.azurerm_network_security_group.nsg.id
}