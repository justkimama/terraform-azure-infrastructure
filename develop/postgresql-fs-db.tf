# PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "db" {
  name                   = "${local.project}-${local.env}-postgresql"
  resource_group_name    = data.azurerm_resource_group.main.name
  location               = data.azurerm_resource_group.main.location
  version                = "15"
  delegated_subnet_id    = azurerm_subnet.db.id
  private_dns_zone_id    = azurerm_private_dns_zone.db.id
  administrator_login    = split("-", local.project)[0]
  administrator_password = "mynewpassword"
  zone                   = "1"
  storage_mb             = 32768
  sku_name               = "B_Standard_B1ms"
  backup_retention_days  = 7
  depends_on             = [azurerm_private_dns_zone_virtual_network_link.db]
  lifecycle {
    ignore_changes = [
      administrator_password,
    ]
  }
}

# PostgreSQL Flexible Server Database
resource "azurerm_postgresql_flexible_server_database" "db" {
  name      = split("-", local.project)[0]
  server_id = azurerm_postgresql_flexible_server.db.id
  collation = "en_US.utf8"
  charset   = "UTF8"
}
