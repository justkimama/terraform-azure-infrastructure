# Azure Container Registry
resource "azurerm_container_registry" "api" {
  name                          = replace("${local.project}${local.env}api", "-", "")
  resource_group_name           = data.azurerm_resource_group.main.name
  location                      = data.azurerm_resource_group.main.location
  sku                           = "Basic"
  admin_enabled                 = true
  public_network_access_enabled = true
  anonymous_pull_enabled        = false

  tags = {
    Source = "terraform"
    Name   = "${local.project}-${local.env}-container-registry"
    Owner  = "OpenAI"
  }
}
