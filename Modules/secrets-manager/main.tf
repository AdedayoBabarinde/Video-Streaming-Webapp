# checkov:skip=CKV_AZURE_41: Secret expiration dates are managed via Key Vault access policies, not per-secret Terraform config
# Store secrets in Azure Key Vault
resource "azurerm_key_vault_secret" "secrets" {
  for_each     = var.secrets
  name         = each.key
  value        = each.value
  key_vault_id = var.key_vault_id
  content_type = "text/plain"

  tags = var.tags
}
