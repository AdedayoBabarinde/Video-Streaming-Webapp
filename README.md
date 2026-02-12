# Netflix-Style Video Streaming Webapp

A full-stack Netflix clone built with React, TypeScript, and Material-UI, powered by the TMDB API. The project includes a complete DevSecOps pipeline with Terraform infrastructure on Azure (AKS/ACR), GitHub Actions CI/CD, Trivy + SonarCloud security scanning, and Prometheus + Grafana monitoring.

![Home Page](app/public/assets/home-page.png)

---

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Architecture Overview](#architecture-overview)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Infrastructure Provisioning](#infrastructure-provisioning)
- [CI/CD Pipeline](#cicd-pipeline)
- [Kubernetes Deployment](#kubernetes-deployment)
- [Monitoring & Observability](#monitoring--observability)
- [Security](#security)
- [Environment Configuration](#environment-configuration)
- [Screenshots](#screenshots)

---

## Features

**Application**
- Netflix-style UI with hero section, genre carousels, and video player
- Browse movies and TV shows via TMDB API integration
- Detail modals with similar recommendations
- Video playback with VideoJS + YouTube plugin
- Infinite scroll grid view with genre-based navigation
- Fully responsive design (mobile, tablet, desktop)
- FastAPI backend for ML-powered text embeddings

**DevOps & Infrastructure**
- Infrastructure as Code with Terraform (modular design)
- Azure AKS clusters with auto-scaling (dev + prod)
- Azure Container Registry for private Docker images
- Azure Key Vault with RBAC authorization for secrets
- Multi-stage Docker builds (Node build -> Nginx serve)
- Kubernetes deployments with HPA, PDB, topology spread, health checks
- Automated CI/CD via GitHub Actions (5 workflows)
- Dev-first deployment with manual promotion to production
- Prometheus + Grafana + Alertmanager monitoring stack
- Trivy container/filesystem vulnerability scanning
- SonarCloud static code analysis (SAST)
- Network policies for namespace isolation

---

## Tech Stack

| Layer | Technologies |
|-------|-------------|
| **Frontend** | React 18, TypeScript, Material-UI v5, Redux Toolkit, RTK Query, Vite, Framer Motion, VideoJS |
| **Backend** | FastAPI, Python 3.10, Sentence Transformers |
| **Containers** | Docker (multi-stage), Nginx Alpine |
| **Orchestration** | Kubernetes (AKS), Helm-compatible manifests |
| **Infrastructure** | Terraform, Azure (AKS, ACR, Key Vault, Log Analytics) |
| **CI/CD** | GitHub Actions (5 workflows) |
| **Security** | Trivy (CVE scanning), SonarCloud (SAST), RBAC, Network Policies |
| **Monitoring** | Prometheus, Grafana, Alertmanager |

---

## Architecture Overview

```
Internet --> Azure Load Balancer --> NGINX Ingress Controller
                                          |
                    +---------------------+---------------------+
                    |                                           |
              /  (frontend)                              /api/* (backend)
                    |                                           |
          netflix-web-service                       netflix-api-service
          (React SPA on Nginx)                      (FastAPI + ML)
                                                          |
                                                    TMDB API (external)
```

**Infrastructure:**
```
Terraform Modules
  ├── resource-group    Azure Resource Groups (per env)
  ├── ACR               Container Registry (AcrPull via managed identity)
  ├── AKS               Kubernetes cluster + Log Analytics
  ├── keyvaults         Key Vault with RBAC authorization
  └── secrets-manager   Secret storage in Key Vault
```

**Environments:**

| | Dev | Prod |
|---|-----|------|
| **AKS Nodes** | 1 (Standard_B2s), auto-scale to 3 | 2-4 (Standard_D2s_v3) |
| **Web Replicas** | 2 | 3 (topology spread) |
| **API Replicas** | 1 | 2 |
| **HPA** | 2-4 pods | 3-10 pods |
| **PDB** | None | minAvailable: 2 |
| **Deploy Trigger** | Auto on merge to main | Manual approval |
| **Security Context** | Standard | Non-root, read-only FS |

> 