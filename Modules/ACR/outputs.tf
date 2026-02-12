output "acr_id" {
  description = "The ID of the container registry"
  value       = azurerm_container_registry.acr.id
}

output "acr_name" {
  description = "The name of the container registry"
  value       = azurerm_container_registry.acr.name
}

output "acr_login_server" {
  description = "The login server URL for the container registry"
  value       = azurerm_container_registry.acr.login_server
}

output "acr_admin_username" {
  description = "The admin username (empty when admin_enabled = false)"
  value       = var.admin_enabled ? azurerm_container_registry.acr.admin_username : ""
}

output "acr_admin_password" {
  description = "The admin password (empty when admin_enabled = false)"
  value       = var.admin_enabled ? azurerm_container_registry.acr.admin_password : ""
  sensitive   = true
}
