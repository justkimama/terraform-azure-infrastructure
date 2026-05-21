# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "${local.project}-${local.env}-main"
  address_space       = ["172.17.0.0/16"]
  location            = local.location
  resource_group_name = "tmp"
  tags = {
    source = "terraform"
    Name   = "${local.project}-${local.env}"
    Owner  = "OpenAI"
  }
}

# App Subnet
resource "azurerm_subnet" "app" {
  name                 = "${local.project}-${local.env}-app"
  resource_group_name  = data.azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["172.17.1.0/24"]
  # サブネット内にNSGを適応するか、Private Endpointを持つ場合はfalse
  private_endpoint_network_policies_enabled = false
  service_endpoints = [
    "Microsoft.CognitiveServices",
    "Microsoft.Sql",
    "Microsoft.Web"
  ]
  delegation {
    name = "delegation"
    service_delegation {
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action",
      ]
      name = "Microsoft.Web/serverFarms"
    }
  }
}

# DB Subnet
resource "azurerm_subnet" "db" {
  name                 = "${local.project}-${local.env}-db"
  resource_group_name  = data.azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["172.17.2.0/24"]
  service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

# ===============================================================================
# bastion subnet
# ===============================================================================
resource "azurerm_subnet" "bastion" {
  name                 = "${local.project}-${local.env}-bastion"
  resource_group_name  = data.azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["172.17.3.0/24"]
}

resource "azurerm_public_ip" "bastion" {
  name                = "${local.project}-${local.env}-bastion-ip"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = local.location
  allocation_method   = "Static"

  tags = {
    environment = "${local.project}-${local.env}"
  }
}
