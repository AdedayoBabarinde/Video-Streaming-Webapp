# Required GitHub Secrets

Configure these secrets in your GitHub repository settings
(Settings > Secrets and variables > Actions):

## Application Secrets
| Secret | Description |
|--------|-------------|
| `TMDB_API_KEY` | TMDB API key for movie data |

## Azure Credentials
| Secret | Description |
|--------|-------------|
| `AZURE_CREDENTIALS` | Azure Service Principal JSON (for azure/login) |
| `ARM_CLIENT_ID` | Azure SP Client ID (for Terraform) |
| `ARM_CLIENT_SECRET` | Azure SP Client Secret (for Terraform) |
| `ARM_SUBSCRIPTION_ID` | Azure Subscription ID (for Terraform) |
| `ARM_TENANT_ID` | Azure AD Tenant ID (for Terraform) |

## Monitoring
| Secret | Description |
|--------|-------------|
| `GRAFANA_ADMIN_PASSWORD` | Grafana admin dashboard password (used by deploy-monitoring workflow) |

## SonarCloud
| Secret | Description |
|--------|-------------|
| `SONAR_TOKEN` | SonarCloud authentication token |
| `SONAR_PROJECT_KEY` | SonarCloud project key |
| `SONAR_ORGANIZATION` | SonarCloud organization name |

## GitHub Environments
Create two environments in Settings > Environments:
1. **dev** - Auto-deploy on merge to main
2. **production** - Requires manual approval (add reviewers)

## Azure Service Principal Setup
```bash
# Create service principal with Contributor role
az ad sp create-for-rbac \
  --name "service principal name" \
  --role contributor \
  --scopes /subscriptions/<SUBSCRIPTION_ID> \
  --sdk-auth
```
