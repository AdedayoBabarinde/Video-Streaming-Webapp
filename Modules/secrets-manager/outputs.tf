output "secret_ids" {
  description = "Map of secret names to their IDs"
  value       = { for k, v in azurerm_key_vault_secret.secrets : k => v.id }
}

output "secret_versions" {
  description = "Map of secret names to their versions"
  value       = { for k, v in azurerm_key_vault_secret.secrets : k => v.version }
}
