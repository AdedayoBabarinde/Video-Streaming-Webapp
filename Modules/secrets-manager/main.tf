# Store secrets in Azure Key Vault
resource "azurerm_key_vault_secret" "secrets" {
  for_each     = var.secrets
  name         = each.key
  value        = each.value
  key_vault_id = var.key_vault_id

  tags = var.tags
}
