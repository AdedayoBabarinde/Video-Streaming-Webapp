# Required GitHub Secrets

Configure these secrets in your GitHub repository settings
(Settings > Secrets and variables > Actions):

## Application Secrets
| Secret | Description |
|--------|-------------|
| `TMDB_API_KEY` | TMDB API key for movie data |

## Azure OIDC Credentials (no client secret required)
| Secret | Description |
|--------|-------------|
| `AZURE_CLIENT_ID` | Azure AD App Registration Client ID |
| `AZURE_TENANT_ID` | Azure AD Tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Azure Subscription ID |

> **Note:** We use OIDC/Workload Identity Federation — no `AZURE_CREDENTIALS` JSON blob
> or `ARM_CLIENT_SECRET` is stored. Run `scripts/setup-oidc.sh` to configure this.

## Monitoring
| Secret | Description |
|--------|-------------|
| `GRAFANA_ADMIN_PASSWORD` | Grafana admin dashboard password |

## Notifications
| Secret | Description |
|--------|-------------|
| `SMTP_USERNAME` | Gmail address for deployment notifications |
| `SMTP_PASSWORD` | Gmail App Password (not your account password) |

## SonarCloud
| Secret | Description |
|--------|-------------|
| `SONAR_TOKEN` | SonarCloud authentication token |
| `SONAR_PROJECT_KEY` | SonarCloud project key |
| `SONAR_ORGANIZATION` | SonarCloud organization name |

## GitHub Environments
Create two environments in Settings > Environments:
1. **dev** — Auto-deploy on merge to main
2. **production** — Requires manual approval (add reviewers)

## OIDC Setup (one-time)
```bash
# Prerequisites: az login, gh auth login
bash scripts/setup-oidc.sh \
  --repo <owner/repo> \
  --set-secrets

# The script will:
#   1. Create an Azure AD app registration
#   2. Grant Contributor + Storage Blob Data Contributor roles
#   3. Add federated credentials for main branch, PRs, dev/production environments
#   4. Set AZURE_CLIENT_ID, AZURE_TENANT_ID, AZURE_SUBSCRIPTION_ID in GitHub
```
