variable "key_vault_id" {
  description = "ID of the Azure Key Vault to store secrets in"
  type        = string
}

variable "secrets" {
  description = "Map of secret names to values to store in Key Vault"
  type        = map(string)
  sensitive   = true
}

variable "tags" {
  description = "Tags to apply to the secrets"
  type        = map(string)
  default     = {}
}
