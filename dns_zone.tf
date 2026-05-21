resource "azurerm_dns_zone" "main" {
  name                = local.base_domain
  resource_group_name = data.azurerm_resource_group.main.name
}
