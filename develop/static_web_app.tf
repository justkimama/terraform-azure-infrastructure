# Static Web App
resource "azurerm_static_site" "front" {
  name                = "${local.project}-${local.env}-front"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = "centralus"
  sku_size            = "Standard"
  sku_tier            = "Standard"

  tags = {
    Source = "terraform"
    Name   = "${local.project}-${local.env}-front"
    Owner  = "OpenAI"
  }
}

# resource "azurerm_static_site_custom_domain" "front" {
#   static_site_id  = azurerm_static_site.front.id
#   validation_type = "cname-delegation"
# }
