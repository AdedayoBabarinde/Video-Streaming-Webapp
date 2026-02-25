# checkov:skip=CKV_AZURE_233: Zone redundancy requires Premium SKU; Basic used for dev/cost efficiency
# checkov:skip=CKV_AZURE_163: Vulnerability scanning requires Premium SKU; not enabled for Basic tier
# checkov:skip=CKV_AZURE_164: Content trust (signed images) requires Premium SKU
# checkov:skip=CKV_AZURE_167: Retention policy for untagged manifests requires Premium SKU
# checkov:skip=CKV_AZURE_237: Dedicated data endpoints require Premium SKU
# checkov:skip=CKV_AZURE_165: Geo-replication requires Premium SKU
# checkov:skip=CKV_AZURE_166: Image quarantine requires Premium SKU
# checkov:skip=CKV_AZURE_139: Disabling public network access requires Premium SKU + private endpoint
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = var.admin_enabled

  tags = var.tags
}
