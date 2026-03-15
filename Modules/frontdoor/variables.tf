variable "frontdoor_name" {
  description = "Name of the Azure Front Door profile (must be globally unique)"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to deploy Front Door into"
  type        = string
}

variable "endpoint_name" {
  description = "Name of the AFD endpoint (globally unique subdomain of azurefd.net)"
  type        = string
}

variable "apex_domain" {
  description = "Apex custom domain to attach (e.g. adedayo.shop). www.{apex_domain} is added automatically."
  type        = string
}

variable "origin_host_name" {
  description = "Hostname or public IP of the AKS ingress Load Balancer (AFD origin)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all Front Door resources"
  type        = map(string)
  default     = {}
}
