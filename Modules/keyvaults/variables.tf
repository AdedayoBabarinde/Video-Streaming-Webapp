variable "key_vault_name" {
  description = "Name of the Azure Key Vault (must be globally unique)"
  type        = string
}

variable "location" {
  description = "Azure region for the Key Vault"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "sku_name" {
  description = "SKU name for the Key Vault (standard or premium)"
  type        = string
  default     = "standard"
}

variable "purge_protection_enabled" {
  description = "Whether purge protection is enabled"
  type        = bool
  default     = false
}

variable "soft_delete_retention_days" {
  description = "Number of days to retain soft-deleted vaults (7-90)"
  type        = number
  default     = 7
}

variable "enable_rbac_authorization" {
  description = "Use Azure RBAC for Key Vault data plane access instead of access policies"
  type        = bool
  default     = true
}

variable "role_assignments" {
  description = "List of RBAC role assignments when enable_rbac_authorization = true"
  type = list(object({
    principal_id = string
    role         = string
  }))
  default = []
}

variable "aks_identity_object_id" {
  description = "Object ID of AKS managed identity (used only when enable_rbac_authorization = false)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to the Key Vault"
  type        = map(string)
  default     = {}
}
