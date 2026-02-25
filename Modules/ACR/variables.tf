variable "acr_name" {
  description = "Name of the Azure Container Registry (must be globally unique, alphanumeric only)"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group where ACR will be created"
  type        = string
}

variable "location" {
  description = "Azure region for the ACR"
  type        = string
}

variable "sku" {
  description = "SKU tier for ACR (Basic, Standard, Premium)"
  type        = string
  default     = "Basic"
}

variable "admin_enabled" {
  description = "Whether admin user is enabled for ACR"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to the ACR"
  type        = map(string)
  default     = {}
}
