# Log Analytics Workspace for App Service
resource "azurerm_log_analytics_workspace" "app_service" {
  name                = "${local.project}-${local.env}-server-log"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = local.location
  sku                 = "PerGB2018"
  retention_in_days   = 90

  tags = {
    Source = "terraform"
    Name   = "${local.project}-${local.env}-server-log"
    Owner  = "OpenAI"
  }
}

# Log Analytics Workspace for DB
resource "azurerm_log_analytics_workspace" "db" {
  name                = "${local.project}-${local.env}-db-log"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = local.location
  sku                 = "PerGB2018"
  retention_in_days   = 90

  tags = {
    Source = "terraform"
    Name   = "${local.project}-${local.env}-db-log"
    Owner  = "OpenAI"
  }
}
