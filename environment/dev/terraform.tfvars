# Dev Environment Configuration
# NOTE: Sensitive values (tmdb_api_key) should be passed via:
#   - Environment variable: TF_VAR_tmdb_api_key
#   - Or CI/CD pipeline secrets

resource_group_name = "netflix-app-dev-rg"
location            = "eastus"
acr_name            = "netflixappdevacr"
aks_cluster_name    = "netflix-app-dev-aks"
dns_prefix          = "netflix-dev"
kubernetes_version  = "1.33"
node_count          = 1
node_vm_size        = "Standard_D2s_v3"
key_vault_name      = "netflix-dev-kv"
