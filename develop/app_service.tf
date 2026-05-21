# App Serivice Plan
resource "azurerm_service_plan" "container" {
  name                = "${local.project}-${local.env}-container"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "B2"

  tags = {
    Source = "terraform"
    Name   = "${local.project}${local.env}-container"
    Owner  = "OpenAI"
  }
}

# Web App
resource "azurerm_linux_web_app" "container" {
  name                      = "${local.project}-${local.env}-app-container"
  resource_group_name       = data.azurerm_resource_group.main.name
  location                  = data.azurerm_resource_group.main.location
  service_plan_id           = azurerm_service_plan.container.id
  https_only                = true
  virtual_network_subnet_id = azurerm_subnet.app.id

  tags = {
    Source = "terraform"
    Name   = "${local.project}-${local.env}-app"
    Owner  = "OpenAI"
  }

  app_settings = {
    # "ADMIN_APP_URL"                              = "http://localhost:8001"
    "AUTH_TYPE"                             = "EASYAUTH"
    "APP_ENV"                               = "production"
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE"   = "false"
    "WEBSITE_TIME_ZONE"                     = "Tokyo Standard Time"
    "DOCKER_REGISTRY_SERVER_URL"            = "https://${azurerm_container_registry.api.login_server}"
    "DOCKER_REGISTRY_SERVER_USERNAME"       = azurerm_container_registry.api.admin_username
    "DOCKER_REGISTRY_SERVER_PASSWORD"       = azurerm_container_registry.api.admin_password
    "LOG_LEVEL"                             = "debug"
    "WEBSITES_PORT"                         = "8000"
    "LOG_LEVEL"                             = "debug"
    "OPENAI_API_BASE"                       = azurerm_cognitive_account.main.endpoint
    "OPENAI_API_EMBEDDINGS_DEPLOYMENT_NAME" = azurerm_cognitive_deployment.embedding.name
    # "OPENAI_API_GPT35_DEPLOYMENT_NAME"      = azurerm_cognitive_deployment.gpt35_turbo.name
    # "OPENAI_API_GPT35_16K_DEPLOYMENT_NAME"  = azurerm_cognitive_deployment.gpt35_turbo_16k.name
    # "OPENAI_API_GPT4_DEPLOYMENT_NAME"       = azurerm_cognitive_deployment.gpt4.name
    "OPENAI_API_KEY"                        = "PleaseChange1234"
    "OPENAI_API_TYPE"                       = "azure"
    "OPENAI_API_VERSION"                    = "2023-08-01-preview"
    "SERPER_API_KEY"                        = "replace_me"
    "VECTOR_INDEX_DRIVER"                   = "faiss"
    "GOOGLE_API_KEY"                        = "PleaseChange1234"
    "GOOGLE_CSE_ID"                         = "PleaseChange1234"
  }

  logs {
    detailed_error_messages = true
    failed_request_tracing  = true

    http_logs {
      file_system {
        retention_in_days = 365
        retention_in_mb   = 35
      }
    }
  }

  site_config {
    application_stack {
      docker_image_name = "${azurerm_container_registry.api.login_server}/${local.project}-${local.env}-api:latest"
    }
    always_on              = false
    health_check_path      = "/ping"
    vnet_route_all_enabled = true
    minimum_tls_version    = "1.2"
    app_command_line       = "/app/startup.sh"
    ftps_state             = "FtpsOnly"

    cors {
      allowed_origins = [
      ]
      support_credentials = true #  support_credentials = false
    }

    dynamic "ip_restriction" {
      for_each = local.ips_priority
      content {
        action     = "Allow"
        headers    = []
        ip_address = ip_restriction.value.ip_address
        priority   = ip_restriction.value.priority
      }
    }

    dynamic "ip_restriction" {
      for_each = local.ips_priority
      content {
        action     = "Allow"
        headers    = []
        ip_address = ip_restriction.value.ip_address
        priority   = ip_restriction.value.priority
      }
    }
  }
  lifecycle {
    ignore_changes = [
      # app_settings["DOCKER_REGISTRY_SERVER_URL"],
      # app_settings["DOCKER_REGISTRY_SERVER_USERNAME"],
      # app_settings["DOCKER_REGISTRY_SERVER_PASSWORD"],
      app_settings,
      # site_config[0].application_stack,
      auth_settings_v2,
      sticky_settings,
    ]
  }
}

# Azure Monitor 診断設定でログを有効化
resource "azurerm_monitor_diagnostic_setting" "container" {
  name                       = "${local.project}-${local.env}-container-log"
  target_resource_id         = azurerm_linux_web_app.container.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.app_service.id
  storage_account_id         = azurerm_storage_account.main.id

  # dynamicブロックを利用して繰り返し
  dynamic "enabled_log" {
    # 以下のカテゴリのログをLog Analyticsに送信
    for_each = [
      "AppServiceAppLogs",
      "AppServiceAuditLogs",
      "AppServiceConsoleLogs",
      "AppServiceHTTPLogs",
      "AppServicePlatformLogs",
      "AppServiceIPSecAuditLogs",
    ]
    content {
      category = enabled_log.value
      # 設定できなくなった。。以下で設定し直す必要あり。
      # https://learn.microsoft.com/ja-jp/azure/azure-monitor/essentials/migrate-to-azure-storage-lifecycle-policy?tabs=portal
      # retention_policy {
      #   enabled = true
      #   days    = local.workspace_retentiondays
      # }
    }
  }

  # 全てのメトリクスを送信
  metric {
    category = "AllMetrics"
    enabled  = true

    # retention_policy {
    #   enabled = true
    #   days    = var.workspace_retentiondays
    # }
  }
}

# カスタムドメインを設定
# resource "azurerm_app_service_custom_hostname_binding" "container" {
#   app_service_name    = azurerm_linux_web_app.container.name
#   resource_group_name = data.azurerm_resource_group.main.name

#   # Managed Cetificate により自動更新されるので変更を無視
#   lifecycle {
#     ignore_changes = [ssl_state, thumbprint]
#   }
# }

# resource "azurerm_app_service_managed_certificate" "container" {
#   custom_hostname_binding_id = azurerm_app_service_custom_hostname_binding.container.id
# }

# resource "azurerm_app_service_certificate_binding" "container" {
#   hostname_binding_id = azurerm_app_service_custom_hostname_binding.container.id
#   certificate_id      = azurerm_app_service_managed_certificate.container.id
#   ssl_state           = "SniEnabled"
# }
