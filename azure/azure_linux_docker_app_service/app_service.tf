
locals {
  # Service plan needs to be unique only within the resource group
  app_service_plan_name = "${var.name_prefix}app-service-plan"
  # Needs to be globally unique
  app_service_name = "${var.name_prefix}${var.app_service_name}"

  # https://github.com/projectkudu/kudu/wiki/Configurable-settings
  app_service_settings = {
    # Enable if you need a persistant file storage (/home/ directory)
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = false

    # Prevent recycling of the app when storage infra changes
    # https://github.com/projectkudu/kudu/wiki/Configurable-settings#disable-the-generation-of-bindings-in-applicationhostconfig
    WEBSITE_ADD_SITENAME_BINDINGS_IN_APPHOST_CONFIG = 1

    APPINSIGHTS_INSTRUMENTATIONKEY = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.current.vault_uri}secrets/app-insights-key)"
  }

  app_service_site_config = {
    always_on                 = true
    min_tls_version           = "1.2"
    health_check_path         = "/api/healthcheck"
    use_32_bit_worker_process = false
  }
}

resource "azurerm_app_service_plan" "current" {
  name                = local.app_service_plan_name
  location            = data.azurerm_resource_group.current.location
  resource_group_name = data.azurerm_resource_group.current.name
  kind                = "linux"
  reserved            = true

  sku {
    tier = var.app_service_plan_tier
    size = var.app_service_plan_size
  }
}

# App service
resource "azurerm_app_service" "current" {
  name                = local.app_service_name
  location            = data.azurerm_resource_group.current.location
  resource_group_name = data.azurerm_resource_group.current.name
  app_service_plan_id = azurerm_app_service_plan.current.id

  https_only = true

  site_config {
    always_on                 = local.app_service_site_config.always_on
    min_tls_version           = local.app_service_site_config.min_tls_version
    health_check_path         = local.app_service_site_config.health_check_path
    use_32_bit_worker_process = local.app_service_site_config.use_32_bit_worker_process
  }

  app_settings = local.app_service_settings

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      app_settings["DOCKER_CUSTOM_IMAGE_NAME"],
      site_config.0.scm_type,
    ]
  }

  logs {
    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 100
      }
    }
  }

  # Use managed identity to login to ACR
  # https://github.com/Azure/app-service-linux-docs/blob/master/HowTo/use_system-assigned_managed_identities.md
  provisioner "local-exec" {
    command = "az resource update --ids ${azurerm_app_service.current.id} --set properties.acrUseManagedIdentityCreds=True -o none"
  }

  # Configure if you need EasyAuth
  # auth_settings {
  # }
}

# Deployment slot for better availability during deployments
resource "azurerm_app_service_slot" "next" {
  name                = "${local.app_service_name}-next"
  resource_group_name = data.azurerm_resource_group.current.name
  location            = data.azurerm_resource_group.current.location
  app_service_name    = azurerm_app_service.current.name
  app_service_plan_id = azurerm_app_service_plan.current.id

  site_config {
    always_on                 = local.app_service_site_config.always_on
    min_tls_version           = local.app_service_site_config.min_tls_version
    health_check_path         = local.app_service_site_config.health_check_path
    use_32_bit_worker_process = local.app_service_site_config.use_32_bit_worker_process
  }

  app_settings = local.app_service_settings

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      app_settings["DOCKER_CUSTOM_IMAGE_NAME"],
      site_config.0.scm_type,
    ]
  }
}
