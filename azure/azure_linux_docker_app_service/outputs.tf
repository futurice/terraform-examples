output "app_service_name" {
  description = "This is the unique name of the App Service that was created"
  value       = azurerm_app_service.current.name
}

output "app_service_url" {
  description = "This is the URL of the App Service that was created"
  value       = azurerm_app_service.current.default_site_hostname
}

output "container_registry" {
  value = azurerm_container_registry.current.login_server
}
