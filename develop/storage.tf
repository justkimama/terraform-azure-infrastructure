# Storage Account
resource "azurerm_storage_account" "main" {
  name                = "dev"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = local.location
  # HDD
  account_tier                     = "Standard"
  account_kind                     = "StorageV2"
  allow_nested_items_to_be_public  = true
  cross_tenant_replication_enabled = false

  account_replication_type = "LRS"
  tags = {
    Source = "terraform"
  }
}

# Storage Account Container
resource "azurerm_storage_container" "app_service_backup" {
  name                  = "appservicebackup"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

data "azurerm_storage_account_blob_container_sas" "containersas"{
  connection_string = azurerm_storage_account.main.primary_connection_string
  container_name = azurerm_storage_container.app_service_backup.name
  https_only = true
  start = "2024-09-05"
  expiry = "2028-09-05"
  permissions {
    read   = true
    add    = true
    create = true
    write  = true
    delete = true
    list   = true
  }
}
