# Since many services require a globally unique name (such as keyvault),
# generate random suffix for the resources
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

locals {
  # Key vault and ACR required globally unique names. Only alphanumeric characters allowed
  key_vault_name = "${local.cleansed_prefix}${random_string.suffix.result}"
  acr_name       = "${local.cleansed_prefix}${random_string.suffix.result}"

  # App insights needs to be unique only within the resource group
  app_insights_name = "${var.name_prefix}app-insights"
}

resource "azurerm_key_vault" "current" {
  name                = local.key_vault_name
  location            = data.azurerm_resource_group.current.location
  resource_group_name = data.azurerm_resource_group.current.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  soft_delete_enabled        = true
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  sku_name = "standard"
}

resource "azurerm_container_registry" "current" {
  name                = local.acr_name
  resource_group_name = data.azurerm_resource_group.current.name
  location            = data.azurerm_resource_group.current.location
  sku                 = "Standard"

  # We'll be using AD login
  admin_enabled = false
}

resource "azurerm_application_insights" "current" {
  name                = local.app_insights_name
  resource_group_name = data.azurerm_resource_group.current.name
  location            = data.azurerm_resource_group.current.location
  application_type    = var.app_insights_app_type
}
