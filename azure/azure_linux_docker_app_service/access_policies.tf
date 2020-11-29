# Key vault access for the current client principal
resource "azurerm_key_vault_access_policy" "principal" {
  key_vault_id = azurerm_key_vault.current.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "get",
    "set",
    "delete"
  ]
}

# Key vault access for the App Service
resource "azurerm_key_vault_access_policy" "app_service" {
  key_vault_id = azurerm_key_vault.current.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azurerm_app_service.current.identity.0.principal_id

  secret_permissions = [
    "get",
  ]
}

# Key vault access for the App Service's next slot
resource "azurerm_key_vault_access_policy" "app_service_next_slot" {
  key_vault_id = azurerm_key_vault.current.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azurerm_app_service_slot.next.identity.0.principal_id

  secret_permissions = [
    "get",
  ]
}

# Pull access for the app service
resource "azurerm_role_assignment" "app_service_acr_pull" {
  scope                = azurerm_container_registry.current.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_app_service.current.identity.0.principal_id
}

# Pull access for the app service's next slot
resource "azurerm_role_assignment" "app_service_next_slot_acr_pull" {
  scope                = azurerm_container_registry.current.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_app_service_slot.next.identity.0.principal_id
}
