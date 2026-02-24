output "resource_group_name" {
  value = module.resource_group.resource_group_name
}

output "acr_login_server" {
  value = module.acr.acr_login_server
}

output "acr_name" {
  value = module.acr.acr_name
}

output "aks_cluster_name" {
  value = module.aks.cluster_name
}

output "kube_config" {
  value     = module.aks.kube_config_raw
  sensitive = true
}

output "key_vault_uri" {
  value = module.keyvault.key_vault_uri
}
