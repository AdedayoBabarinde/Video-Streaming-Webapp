# checkov:skip=CKV_AZURE_189: Disabling public network access requires private endpoint infrastructure
# checkov:skip=CKV_AZURE_109: Firewall rules enforcement requires private endpoint; would block all access in dev
# checkov:skip=CKV2_AZURE_32: Private endpoint for Key Vault requires private DNS zones and VPN infrastructure
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                       = var.key_vault_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = var.sku_name
  soft_delete_retention_days = var.soft_delete_retention_days
  purge_protection_enabled   = var.purge_protection_enabled
  enable_rbac_authorization  = var.enable_rbac_authorization

  # Only create access_policy when NOT using RBAC
  dynamic "access_policy" {
    for_each = var.enable_rbac_authorization ? [] : [1]
    content {
      tenant_id = data.azurerm_client_config.current.tenant_id
      object_id = data.azurerm_client_config.current.object_id

      secret_permissions = [
        "Get",
        "List",
        "Set",
        "Delete",
        "Purge",
      ]
    }
  }

  tags = var.tags
}

# When NOT using RBAC: grant AKS identity via access_policy
resource "azurerm_key_vault_access_policy" "aks" {
  count        = (!var.enable_rbac_authorization && var.aks_identity_object_id != "") ? 1 : 0
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.aks_identity_object_id

  secret_permissions = [
    "Get",
    "List",
  ]
}

# When using RBAC: assign roles from the role_assignments list
resource "azurerm_role_assignment" "kv_roles" {
  count                = var.enable_rbac_authorization ? length(var.role_assignments) : 0
  scope                = azurerm_key_vault.kv.id
  role_definition_name = var.role_assignments[count.index].role
  principal_id         = var.role_assignments[count.index].principal_id
}

# Grant the deploying SP "Key Vault Secrets Officer" so Terraform can manage secrets
resource "azurerm_role_assignment" "deployer_secrets_officer" {
  count                = var.enable_rbac_authorization ? 1 : 0
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}
