# Netflix-Style Video Streaming Webapp

A full-stack Netflix clone built with **React 18 + TypeScript + Material-UI**, powered by the TMDB API.
Backed by a complete **DevSecOps pipeline** on Azure: Terraform IaC, GitHub Actions CI/CD, 
AKS with multi-zone node pools, Blue/Green deployments, Helm-managed monitoring, and automated
 TLS via cert-manager +  Encrypted on **adedayo.shop**.

![Home Page](app/public/assets/home-page.png)

---

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Architecture Overview](#architecture-overview)
- [Project Structure](#project-structure)
- [Environment Comparison (Dev vs Prod)](#environment-comparison-dev-vs-prod)
- [CI/CD Pipelines](#cicd-pipelines)
- [Security Layers](#security-layers)
- [Monitoring & Observability](#monitoring--observability)
- [Getting Started](#getting-started)
- [Documentation](#documentation)

---

## Features

### Application
- Netflix-style UI — hero section, genre carousels, infinite scroll, detail modals
- Movies & TV shows via **TMDB API** (v3)
- Video playback with **VideoJS** + YouTube plugin
- Fully responsive design (mobile, tablet, desktop)
- **FastAPI** backend with **Sentence Transformers** ML embeddings for similarity search

### Infrastructure & DevOps
- **Modular Terraform** IaC on Azure (AKS, ACR, Key Vault, custom VNet)
- **Multi-zone AKS node pools** — system pool (zone 1) + app pool (zone 2) for high availability
- **Custom VNet** with 3 segmented subnets and NSG rules (no direct Internet access to node pools)
- **Azure CNI** networking with Azure Network Policy enforcement
- **OIDC/Workload Identity Federation** — no long-lived secrets stored anywhere
- **Blue/Green deployments** for production — zero-downtime releases with instant rollback
- **cert-manager** + Encryption and automatic TLS for `adedayo.shop` and `dev.adedayo.shop`
- **Helm-managed monitoring** via `kube-prometheus-stack`
- **6 GitHub Actions workflows** covering build, deploy, infrastructure, monitoring, Blue/Green, and DAST

### Security
- **Trivy** — container image and filesystem CVE scanning
- **SonarCloud** — SAST quality gate (blocks deploy on failure)
- **Checkov** — IaC security scanning (Terraform + Kubernetes manifests → GitHub Security tab)
- **OWASP ZAP** — dynamic application security testing (DAST) on production
- **Kubernetes Network Policies** — deny-all default, allow-list per service
- **Non-root containers** — all pods run as UID 1001, port 8080
- **RBAC** throughout — Key Vault Secrets User, AcrPull via managed identity
- **PodDisruptionBudget** on production — `minAvailable: 2`

---

## Tech Stack

| Layer | Technologies |
|-------|-------------|
| **Frontend** | React 18, TypeScript, Material-UI v5, Redux Toolkit, RTK Query, Vite, Framer Motion, VideoJS |
| **Backend** | FastAPI, Python 3.10, Sentence Transformers (all-MiniLM-L6-v2) |
| **Containers** | Docker (multi-stage), Nginx 1.25 Alpine (port 8080, non-root) |
| **Orchestration** | Kubernetes 1.33 on AKS, Helm 3 |
| **Networking** | Azure CNI, Azure Network Policy, custom VNet, NSGs, Nginx Ingress Controller |
| **TLS** | cert-manager, Encryption ACME HTTP-01 |
| **Infrastructure** | Terraform ~> 4.0 (azurerm), Azure AKS, ACR, Key Vault, Log Analytics |
| **CI/CD** | GitHub Actions (6 workflows), OIDC federation |
| **Security** | Trivy, SonarCloud, Checkov, OWASP ZAP, RBAC, Network Policies |
| **Monitoring** | kube-prometheus-stack (Prometheus, Grafana, Alertmanager, kube-state-metrics) |
| **DNS** | GoDaddy — adedayo.shop |

---

## Architecture Overview

### System Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│  Internet / End Users                                                    │
│  adedayo.shop  ·  www.adedayo.shop  ·  dev.adedayo.shop                 │
└──────────────────────────────┬──────────────────────────────────────────┘
                               │ HTTPS ( Encrypted TLS)
                               ▼
          GoDaddy DNS (A record → Ingress IP)
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────────────┐
│  Azure Kubernetes Service (AKS 1.33)                                     │
│                                                                          │
│  Ingress Subnet (10.x.3.0/24)                                           │
│  ┌───────────────────────────────────────────────────────────────────┐  │
│  │  ingress-nginx (LoadBalancer)  ·  cert-manager                   │  │
│  └──────────────────┬────────────────────────┬──────────────────────┘  │
│                     │ /                       │ /api                    │
│  App Subnet (10.x.2.0/24)  ·  Availability Zone 2                      │
│  ┌───────────────────────┐   ┌──────────────────────────────────────┐  │
│  │  netflix-web          │   │  netflix-api                         │  │
│  │  React + Nginx        │   │  FastAPI + Sentence Transformers     │  │
│  │  port 8080, UID 1001  │   │  port 80, 2Gi RAM limit              │  │
│  │  HPA: 2-4 / 3-10      │   │  HPA (tied to web)                  │  │
│  └───────────────────────┘   └──────────────────────────────────────┘  │
│                                                                          │
│  System Subnet (10.x.1.0/24)  ·  Availability Zone 1                   │
│  ┌───────────────────────────────────────────────────────────────────┐  │
│  │  kube-system  ·  cert-manager  ·  monitoring namespace           │  │
│  │  Prometheus  ·  Grafana  ·  Alertmanager  ·  kube-state-metrics  │  │
│  └───────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────┘
         │                           │
         ▼                           ▼
┌──────────────────┐      ┌──────────────────────────┐
│ Azure ACR         │      │ Azure Key Vault (RBAC)    │
│ Dev: Basic SKU    │      │ kubelet → Secrets User    │
│ Prod: Standard    │      │ purge-protection 90d      │
└──────────────────┘      └──────────────────────────┘
```

### VNet Network Segmentation

```
Azure VNet  (Dev: 10.0.0.0/16  |  Prod: 10.1.0.0/16)
├── aks-system subnet  (zone 1)   NSG: deny Internet in, allow VNet
├── aks-app    subnet  (zone 2)   NSG: deny Internet in, allow VNet
└── ingress    subnet             NSG: allow :80 and :443 from Internet
```

### Terraform Module Graph

```
resource-group
  ├── networking  (VNet, subnets, NSGs)
  ├── ACR
  └── AKS  (depends on networking + ACR)
        └── keyvaults  (depends on AKS kubelet identity)
```

---

## Project Structure

```
netflix-streaming-webapp/
│
├── app/                         # Application code
│   ├── src/                     # React TypeScript source
│   │   ├── pages/               # HomePage, GenreExplore, WatchPage
│   │   ├── components/          # 50+ UI components
│   │   ├── store/               # Redux Toolkit + RTK Query (TMDB API)
│   │   ├── hooks/               # Custom hooks (intersection observer, etc.)
│   │   ├── providers/           # React context providers
│   │   ├── layouts/             # MainLayout (header + footer)
│   │   └── theme/               # MUI dark Netflix theme
│   ├── main.py                  # FastAPI backend (ML embeddings)
│   ├── requirements.txt         # Python dependencies
│   ├── Dockerfile               # FastAPI container
│   ├── Dockerfile.frontend      # React multi-stage → Nginx (port 8080)
│   └── nginx.conf               # Non-root Nginx config (port 8080)
│
├── Modules/                     # Terraform module library
│   ├── resource-group/          # Azure Resource Group
│   ├── networking/              # VNet + subnets + NSGs
│   ├── ACR/                     # Azure Container Registry
│   ├── AKS/                     # AKS cluster (multi-zone node pools, OIDC)
│   ├── keyvaults/               # Key Vault + RBAC
│   └── secrets-manager/         # Key Vault secret storage
│
├── environment/                 # Environment-specific Terraform configs
│   ├── dev/                     # Dev: main.tf, variables.tf, terraform.tfvars
│   └── prod/                    # Prod: main.tf, variables.tf, terraform.tfvars
│
├── k8s/                         # Kubernetes manifests
│   ├── base/                    # Shared: namespaces, configmaps, network-policies,
│   │                            #         cert-manager-issuers
│   ├── dev/                     # Dev: deployment, service, ingress, hpa
│   ├── prod/                    # Prod: deployment, service, ingress, hpa, pdb
│   │   └── blue-green/          # Blue/Green: deployment-blue, deployment-green, services
│   └── monitoring/              # kube-prometheus-stack Helm values,
│                                #   Netflix custom Grafana dashboard ConfigMap
│
├── .github/
│   ├── workflows/
│   │   ├── ci.yml               # PR: build, TypeScript, Trivy, SonarCloud, Checkov
│   │   ├── deploy-dev.yml       # Auto-deploy to dev on push to main
│   │   ├── deploy-prod.yml      # Manual prod deploy with approval gate
│   │   ├── terraform.yml        # Terraform plan / apply / destroy
│   │   ├── deploy-monitoring.yml# Helm: kube-prometheus-stack
│   │   ├── blue-green-deploy.yml# Blue/Green: deploy-and-switch, rollback
│   │   └── dast-zap-scan.yml    # OWASP ZAP dynamic security scan
│   └── SECRETS_REQUIRED.md      # All required GitHub secrets
│
├── scripts/
│   ├── setup-env.sh             # Dev/prod environment variables setup
│   ├── setup-env.ps1            # Windows PowerShell version
│   ├── setup-oidc.sh            # One-time OIDC federation setup
│   └── setup-dns.sh             # GoDaddy DNS record configuration
│
└── docs/
    ├── BUILD_GUIDE.md           # Step-by-step full build guide (17 sections)
    └── ARCHITECTURE.md          # 9 detailed ASCII architecture diagrams
```

---

## Environment Comparison (Dev vs Prod)

| | Dev | Prod |
|---|-----|------|
| **Domain** | `dev.adedayo.shop` | `adedayo.shop` + `www.adedayo.shop` |
| **TLS Issuer** | Let's Encrypt Staging | Let's Encrypt Production |
| **ACR SKU** | Basic | Standard |
| **VNet CIDR** | 10.0.0.0/16 | 10.1.0.0/16 |
| **System node pool** | zone 1, 1 node, autoscale 1–3 | zone 1, 1 node, autoscale 1–3 |
| **App node pool** | zone 2, 1 node, autoscale 1–5 | zone 2, 2 nodes, autoscale 2–6 |
| **VM size** | Standard_D2s_v3 | Standard_D2s_v3 |
| **Web replicas** | 2 | 3 (topology spread across nodes) |
| **API replicas** | 1 | 2 |
| **HPA (web)** | min 2, max 4 | min 3, max 10 |
| **PDB** | None | `minAvailable: 2` |
| **Security context** | Standard | `runAsUser=1001`, `runAsNonRoot=true` |
| **Key Vault soft-delete** | 90 days | 90 days + purge protection |
| **Log Analytics retention** | 30 days | 90 days |
| **Deploy trigger** | Auto on merge to main | Manual `workflow_dispatch` + approval |
| **Blue/Green** | No | Yes (blue-green-deploy.yml) |
| **Trivy exit code** | 0 (report only) | 1 (blocks on CRITICAL) |
| **Ingress-nginx replicas** | 1 | 2 (`externalTrafficPolicy=Local`) |

---

## CI/CD Pipelines

### Workflow Map

```
Pull Request to main
  └── ci.yml ──► TypeScript build → SonarCloud SAST → Trivy FS scan
                 → Trivy image scan → Checkov IaC scan
                 All results → GitHub Security tab (SARIF)

Merge to main (automatic)
  └── deploy-dev.yml ──► SonarCloud gate
                         → docker build + push to dev ACR (git SHA tag)
                         → Trivy scan
                         → helm install ingress-nginx + cert-manager
                         → kubectl apply (dev manifests)
                         → rollout status
                         → email notification

Manual trigger
  └── terraform.yml ──► OIDC login → tf init → Checkov → tf plan
                        (action=apply) → tf apply with approval gate
                        (action=destroy) → tf destroy

  └── deploy-prod.yml ──► validate "deploy-prod" confirmation
                          → SonarCloud gate
                          → az acr import (dev → prod ACR, no rebuild)
                          → Trivy CRITICAL scan (exit-code: 1)
                          → GitHub environment approval gate
                          → helm install ingress-nginx + cert-manager
                          → kubectl apply (prod manifests)
                          → smoke test (curl /health + /api/)
                          → email notification with Ingress IP

  └── deploy-monitoring.yml ──► helm install kube-prometheus-stack
                                → apply Netflix custom dashboard ConfigMap

  └── blue-green-deploy.yml ──► deploy-and-switch  (deploy to inactive slot, switch traffic)
                                switch-only         (traffic flip without deploy)
                                rollback            (revert service selector to previous slot)

  └── dast-zap-scan.yml ──► OWASP ZAP baseline + full + API scan on production
```

### OIDC Authentication Flow

All workflows authenticate to Azure using **OIDC federated identity** — no client secrets stored:

```
GitHub Actions runner
  → generates OIDC token (signed by github.com)
  → azure/login@v2 exchanges it for an Azure access token
  → short-lived token used by az CLI + terraform (ARM_USE_OIDC=true)
  → no secrets stored in GitHub, no rotation needed
```

Setup (one-time): `bash scripts/setup-oidc.sh --repo <owner/repo> --set-secrets`

Required GitHub secrets (3 total, no passwords):

| Secret | Description |
|--------|-------------|
| `AZURE_CLIENT_ID` | App Registration Client ID |
| `AZURE_TENANT_ID` | Azure AD Tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Azure Subscription ID |

---

## Security Layers

| Layer | Tool | When |
|-------|------|------|
| SAST | SonarCloud | Every PR + before deploy |
| Container CVE | Trivy (image) | After docker build |
| Filesystem CVE | Trivy (fs) | Every PR |
| IaC security | Checkov (Terraform + K8s) | Every PR + terraform plan |
| Dynamic security | OWASP ZAP | After prod deploy |
| Secret management | OIDC (no secrets) + Key Vault | Runtime |
| Network isolation | K8s Network Policies + NSGs | Runtime |
| Pod security | Non-root (UID 1001), port 8080 | Runtime |
| Availability | PDB minAvailable=2 (prod) | Runtime |

---

## Monitoring & Observability

Monitoring is deployed via Helm (`kube-prometheus-stack`) into the `monitoring` namespace.

**Components included:**
- **Prometheus** — metrics collection, 15s scrape interval, 15-day retention
- **Grafana** — dashboards (LoadBalancer service, port 80)
- **Alertmanager** — alert routing (configurable: Slack/email/PagerDuty)
- **kube-state-metrics** — deployment/pod/node state metrics
- **node-exporter** — per-node CPU/memory/disk/network

**Custom Netflix Dashboard (auto-provisioned):**
- Pod CPU and memory usage
- Available replicas per deployment
- Pod restarts (last 1 hour)
- Container running status
- Network I/O (RX/TX per pod)
- HPA current vs desired replicas

**Deploy monitoring:**
```
GitHub → Actions → Deploy Monitoring Stack → environment: dev|prod
```

**Access Grafana:**
```bash
kubectl get svc kube-prometheus-stack-grafana -n monitoring
# Open http://<EXTERNAL-IP>  (admin / <GRAFANA_ADMIN_PASSWORD>)
# Navigate to: Dashboards → Netflix Streaming App
```

---

## Getting Started

### Prerequisites

```bash
node --version   # 18+
python --version # 3.10+
docker version
az version       # Azure CLI 2.50+
terraform version # 1.5+
kubectl version --client
helm version     # 3.12+
gh version       # GitHub CLI 2.30+
```

### Local Development

**Frontend:**
```bash
cd app
cp .env.example .env      # add VITE_APP_TMDB_V3_API_KEY=<your_key>
npm install
npm run dev               # → http://localhost:5173
```

**Backend API:**
```bash
cd app
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --reload  # → http://localhost:8000
```

**Docker (both services):**
```bash
cd app
docker build -f Dockerfile.frontend \
  --build-arg VITE_APP_TMDB_V3_API_KEY=<key> \
  -t netflix-app:local .
docker run -p 8080:8080 netflix-app:local

docker build -f Dockerfile -t netflix-api:local .
docker run -p 8000:80 netflix-api:local
```

### Full Deployment (summary)

```bash
# 1. Bootstrap Azure state storage (one-time)
source scripts/setup-env.sh dev --setup-backend
source scripts/setup-env.sh prod --setup-backend

# 2. Configure OIDC (one-time)
bash scripts/setup-oidc.sh --repo <owner/repo> --set-secrets

# 3. Add remaining GitHub secrets manually (TMDB_API_KEY, GRAFANA_ADMIN_PASSWORD, etc.)
#    See .github/SECRETS_REQUIRED.md

# 4. Create GitHub environments: dev (no gates) + production (reviewer required)

# 5. Provision infrastructure
cd environment/dev && terraform init && terraform apply
cd environment/prod && terraform init && terraform apply

# 6. Push to main → deploy-dev.yml triggers automatically

# 7. Deploy monitoring
#    GitHub → Actions → Deploy Monitoring Stack → dev

# 8. Configure DNS (after Ingress IP is assigned)
bash scripts/setup-dns.sh    # prints DNS records for GoDaddy

# 9. Promote to prod
#    GitHub → Actions → Deploy to Production → image_tag=<sha7> + confirm_deploy=deploy-prod
```

**For full step-by-step instructions, see [docs/BUILD_GUIDE.md](docs/BUILD_GUIDE.md).**

---

## Documentation

| Document | Description |
|----------|-------------|
| [docs/BUILD_GUIDE.md](docs/BUILD_GUIDE.md) | Complete 17-section build guide: prerequisites → local dev → Azure bootstrap → OIDC → Terraform → CI/CD → Blue/Green → DNS/TLS → teardown → troubleshooting |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | 9 ASCII architecture diagrams: system overview, VNet topology, CI/CD pipeline, K8s cluster layout, OIDC chain, data flow, secret management, monitoring flow, Terraform dependency graph |
| [.github/SECRETS_REQUIRED.md](.github/SECRETS_REQUIRED.md) | All required GitHub secrets with descriptions and OIDC setup instructions |

---

## Screenshots

> Add screenshots of the running application, Grafana dashboards, and GitHub Actions runs here.

---

## License

MIT
