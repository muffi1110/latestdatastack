module "resource_group" {
  source               = "../../modules/resource_group"
  resource_group_name  = var.resource_group_name
  location             = var.location
  tags                 = var.tags
}

data "azurerm_resource_group" "AzureRG" {
  name = var.resource_group_name

  depends_on = [ module.resource_group ]
}

data "azurerm_route_table" "AzureRT" {
  name = var.route_table_name
  resource_group_name = var.resource_group_name

  depends_on = [ module.resource_group, module.route_table ]
}

data "azurerm_network_security_group" "AzureNSG" {
  name = var.nsg_name
  resource_group_name = var.resource_group_name

  depends_on = [ module.resource_group, module.nsg ]
}

module "nsg" {
  source               = "../../modules/nsg"
  resource_group_name  = var.resource_group_name
  location             = var.location
  nsg_name             = var.nsg_name
  tags                 = var.tags

  depends_on = [ module.resource_group ]
}

module "route_table" {
  source               = "../../modules/route_table"
  resource_group_name  = var.resource_group_name
  location             = var.location
  route_table_name     = var.route_table_name
  tags                 = var.tags

  depends_on = [ module.resource_group ]
}

module "vnet" {
  source               = "../../modules/vnet"
  resource_group_name  = var.resource_group_name
  location             = var.location
  vnet_name            = var.vnet_name
  vnet_address_space   = var.vnet_address_space
  nsg_name = var.nsg_name

  pub_subnet_az1 = var.pub_subnet_az1
  pub_subnet_az2 = var.pub_subnet_az2
  pub_subnet_az3 = var.pub_subnet_az3
  pub_sqlsubnet = var.pub_sqlsubnet

  private_subnet_az1 = var.private_subnet_az1
  private_subnet_az2 = var.private_subnet_az2
  private_subnet_az3 = var.private_subnet_az3

  subnet_address_prefix_pub_az1 = var.subnet_address_prefix_pub_az1
  subnet_address_prefix_pub_az2 = var.subnet_address_prefix_pub_az2
  subnet_address_prefix_pub_az3 = var.subnet_address_prefix_pub_az3
  subnet_address_prefix_sqlsubnet = var.subnet_address_prefix_sqlsubnet

  subnet_address_prefix_private_az1 =  var.subnet_address_prefix_private_az1
  subnet_address_prefix_private_az2 = var.subnet_address_prefix_private_az2
  subnet_address_prefix_private_az3 = var.subnet_address_prefix_private_az3

  
  nsg_id               = data.azurerm_network_security_group.AzureNSG.id
  route_table_id       = data.azurerm_route_table.AzureRT.id
  tags                 = var.tags

  depends_on = [ module.resource_group, module.nsg, module.route_table ]
}

# module "sqlserver" {
#   source = "../../modules/sqlserver"

#   resource_group_name = var.resource_group_name
#   #location = "Norwayeast"
#   vnet_name = var.vnet_name
#   subnet_name = var.pub_sqlsubnet

#   depends_on = [ module.resource_group, module.vnet ]
# }

# module "azuredatabrick" {
#   source = "../../modules/sqlserver"
 
#  resource_group_name = var.resource_group_name
#  location = var.location
# }

module "azuredatalakeGen" {
  source = "../../modules/DataGen2"

  resource_group_name = var.resource_group_name
  datafactory_name = var.datafactory_name
  adlgstg_name = var.adlgstg_name
  location = var.location
  vnet_name = var.vnet_name
  private_subnet_az1 = var.private_subnet_az1

  depends_on = [ module.nsg,module.resource_group]
}

module "AzureDataFactory" {
  source = "../../modules/ADF"

  resource_group_name = var.resource_group_name
  datafactory_name = var.datafactory_name
  adlgstg_name = var.adlgstg_name
  location = var.location
  private_subnet_az1 = var.private_subnet_az1
  vnet_name = var.vnet_name

  depends_on = [ module.resource_group, module.vnet, module.azuredatalakeGen]
}
