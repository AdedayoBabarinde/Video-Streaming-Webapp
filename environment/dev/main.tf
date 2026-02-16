# ============================================================
#  main.tf — 
# ============================================================

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstatenetflixdev"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
     # we Use managed identity for state access instead of storage keys
    use_azuread_auth = true
  }
}

provider "azurerm" {
  features {
    key_vault {
      # For security, do not allow soft-deleted vaults to be purged or recovered by Terraform destroy
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
  }
}

# -------------------------------------------------------
# Resource Group
# -------------------------------------------------------
module "resource_group" {
  source              = "../../Modules/resource-group"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = local.common_tags
}

# -------------------------------------------------------
# Azure Container Registry
# -------------------------------------------------------
module "acr" {
  source = "../../Modules/ACR"

  acr_name            = var.acr_name
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.location
  sku                 = "Basic"

  #  use AKS managed identity with AcrPull role
  admin_enabled = false

  tags = local.common_tags
}

# -------------------------------------------------------
# Azure Kubernetes Service 
# -------------------------------------------------------
module "aks" {
  source = "../../Modules/AKS"

  cluster_name        = var.aks_cluster_name
  location            = module.resource_group.location
  resource_group_name = module.resource_group.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version
  node_count          = var.node_count
  node_vm_size        = var.node_vm_size
  os_disk_size_gb     = 30

  # Enable autoscaling for resilience
  enable_auto_scaling = true
  min_count           = var.node_count
  max_count           = var.node_count * 3

  # AcrPull role assignment via managed identity
  attach_acr = true
  acr_id     = module.acr.acr_id

  
  create_log_analytics = true
  log_retention_days   = 30

  tags = local.common_tags

  depends_on = [module.resource_group]
}

# -------------------------------------------------------
# Azure Key Vault
# -------------------------------------------------------
module "keyvault" {
  source = "../../Modules/keyvaults"

  key_vault_name      = var.key_vault_name
  location            = module.resource_group.location
  resource_group_name = module.resource_group.resource_group_name
  sku_name            = "standard"

  # Enable purge protection to prevent permanent secret deletion
  purge_protection_enabled   = true
  soft_delete_retention_days = 90

  #Use RBAC with least-privilege (Secret User = read-only)
  enable_rbac_authorization = true

  role_assignments = [
    {
      principal_id = module.aks.kubelet_identity_object_id
      role         = "Key Vault Secrets User"
    }
  ]

  tags = local.common_tags

  depends_on = [module.aks]
}



# -------------------------------------------------------
# Locals
# -------------------------------------------------------
locals {
  common_tags = {
    Environment = "dev"
    Project     = "netflix-streaming-app"
    ManagedBy   = "terraform"
  }
}

# ============================================================
# TODO (PROD): Before promoting to production, add:
#   - Network module with VNet/subnets (Azure CNI + Calico)
#   - Private cluster mode for AKS
#   - Private endpoints for ACR (upgrade to Standard/Premium SKU)
#   - Private endpoints for Key Vault
#   - Network ACLs on Key Vault (restrict to AKS subnet)
#   - Separate Log Analytics module
#   - Microsoft Defender and Azure Policy on AKS
# ============================================================
