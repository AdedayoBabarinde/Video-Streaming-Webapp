variable "vnet_name" {
  description = "Name of the Virtual Network"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the VNet"
  type        = string
  default     = "10.0.0.0/16"
}

variable "aks_system_subnet_cidr" {
  description = "CIDR for the AKS system node pool subnet (zone 1)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "aks_app_subnet_cidr" {
  description = "CIDR for the AKS app node pool subnet (zone 2)"
  type        = string
  default     = "10.0.2.0/24"
}

variable "ingress_subnet_cidr" {
  description = "CIDR for the ingress/load balancer subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
