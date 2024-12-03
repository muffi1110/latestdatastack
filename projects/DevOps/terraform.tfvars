# terraform.tfvars

# General Configuration
resource_group_name  = "bq-stgn-rg"
location             = "Norwayeast"
tags = {
  Environment = "bachemstg"
  Project     = "Tebachemdataplatform"
}

# Virtual Network (VNet) Configuration
vnet_name            = "bq-stgn-vnet"
vnet_address_space   = ["10.3.0.0/16"]

# Subnet Configuration
pub_subnet_az1 = "public-subnet-az1"
pub_subnet_az2 = "public-subnet-az2"
pub_subnet_az3 = "public-subnet-az3"

pub_sqlsubnet = "sql-subnet"

subnet_address_prefix_pub_az1 = [ "10.3.5.0/24" ]
subnet_address_prefix_pub_az2 = [ "10.3.6.0/24" ]
subnet_address_prefix_pub_az3 = [ "10.3.7.0/24" ]

subnet_address_prefix_sqlsubnet = [ "10.3.8.0/24" ]

private_subnet_az1 = "private-subnet-az1"
private_subnet_az2 = "private-subnet-az2"
private_subnet_az3 = "private-subnet-az3"

subnet_address_prefix_private_az1 = [ "10.3.11.0/24" ]
subnet_address_prefix_private_az2 = [ "10.3.12.0/24" ]
subnet_address_prefix_private_az3 = [ "10.3.13.0/24" ]

# Network Security Group (NSG) Configuration
nsg_name             = "bq-stgn-nsg"

# Route Table Configuration
route_table_name     =  "bq-stgn-routetable"

#update the adf name
datafactory_name = "bq-stgn-mufadfprod"

#update adl stg name
adlgstg_name = "stgbqstgnadenew111"