variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "location" {
  description = "Azure region for the AKS cluster"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the AKS cluster"
  type        = string
  default     = "1.33"
}

variable "os_disk_size_gb" {
  description = "OS disk size in GB for each node"
  type        = number
  default     = 30
}

# -------------------------------------------------------
# System node pool (zone 1)
# -------------------------------------------------------
variable "system_node_count" {
  description = "Initial node count for the system node pool"
  type        = number
  default     = 1
}

variable "system_node_vm_size" {
  description = "VM size for the system node pool"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "system_min_count" {
  description = "Minimum node count for system pool autoscaling"
  type        = number
  default     = 1
}

variable "system_max_count" {
  description = "Maximum node count for system pool autoscaling"
  type        = number
  default     = 3
}

variable "system_subnet_id" {
  description = "Subnet ID for the system node pool (zone 1)"
  type        = string
  default     = ""
}

# -------------------------------------------------------
# App node pool (zone 2)
# -------------------------------------------------------
variable "app_node_count" {
  description = "Initial node count for the app node pool"
  type        = number
  default     = 1
}

variable "app_node_vm_size" {
  description = "VM size for the app node pool"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "app_min_count" {
  description = "Minimum node count for app pool autoscaling"
  type        = number
  default     = 1
}

variable "app_max_count" {
  description = "Maximum node count for app pool autoscaling"
  type        = number
  default     = 5
}

variable "app_subnet_id" {
  description = "Subnet ID for the app node pool (zone 2)"
  type        = string
  default     = ""
}

# -------------------------------------------------------
# ACR integration
# -------------------------------------------------------
variable "attach_acr" {
  description = "Whether to create an AcrPull role assignment for this cluster"
  type        = bool
  default     = false
}

variable "acr_id" {
  description = "ID of the ACR to grant pull access to (required when attach_acr = true)"
  type        = string
  default     = ""
}

# -------------------------------------------------------
# Log Analytics
# -------------------------------------------------------
variable "log_analytics_workspace_id" {
  description = "ID of an external Log Analytics workspace for OMS agent (used when create_log_analytics = false)"
  type        = string
  default     = ""
}

variable "create_log_analytics" {
  description = "Whether to create a new Log Analytics workspace"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Number of days to retain logs in Log Analytics"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
