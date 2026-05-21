# Private DNS zone for DB
resource "azurerm_private_dns_zone" "db" {
  name                = "${local.project}-${local.env}-db.private.postgres.database.azure.com"
  resource_group_name = data.azurerm_resource_group.main.name
  tags = {
    Source = "terraform"
    Name   = "${local.project}-db.private.postgres.database.azure.com"
    Owner  = "OpenAI"
  }
}
# Private DNS zone Virtual Network Link for DB
resource "azurerm_private_dns_zone_virtual_network_link" "db" {
  name                  = "${local.project}-${local.env}-db-private-networklink"
  private_dns_zone_name = azurerm_private_dns_zone.db.name
  resource_group_name   = data.azurerm_resource_group.main.name
  virtual_network_id    = azurerm_virtual_network.main.id
  tags = {
    Source = "terraform"
    Name   = "${local.project}-db-private-networklink"
    Owner  = "OpenAI"
  }
}

# Private Endpoint for Storage
# resource "azurerm_private_endpoint" "storage" {
#   name                          = "${local.project}-storage-private-endpoint"
#   custom_network_interface_name = "${local.project}-storage-private-endpoint-nic"
#   location                      = local.location
#   resource_group_name           = data.azurerm_resource_group.main.name
#   subnet_id                     = azurerm_subnet.app.id

#   private_service_connection {
#     name                           = "${local.project}-storage-private-endpoint"
#     private_connection_resource_id = azurerm_storage_account.main.id
#     subresource_names              = ["blob"]
#     is_manual_connection           = false
#   }

#   private_dns_zone_group {
#     name                 = "default"
#     private_dns_zone_ids = [azurerm_private_dns_zone.storage.id]
#   }

#   tags = {
#     Source = "terraform"
#     Name   = "${local.project}-storage-private-endpoint"
#     Owner  = "OpenAI"
#   }
# }

# Private DNS zone for Storage
resource "azurerm_private_dns_zone" "storage" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = data.azurerm_resource_group.main.name
  tags = {
    Source = "terraform"
    Name   = "privatelink.file.core.windows.net"
    Owner  = "OpenAI"
  }
}

# Private DNS zone Virtual Network Link for Storage
resource "azurerm_private_dns_zone_virtual_network_link" "storage" {
  name                  = "${local.project}-${local.env}-strage-private-networklink"
  private_dns_zone_name = azurerm_private_dns_zone.storage.name
  resource_group_name   = data.azurerm_resource_group.main.name
  virtual_network_id    = azurerm_virtual_network.main.id
  tags = {
    Source = "terraform"
    Name   = "${local.project}-strage-private-networklink"
    Owner  = "OpenAI"
  }
}
