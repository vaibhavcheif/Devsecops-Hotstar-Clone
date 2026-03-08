# 🎬 DevSecOps Hotstar Clone

A production-grade **DevSecOps** project that deploys a **React.js Hotstar Clone** application through a fully automated, security-integrated CI/CD pipeline on **AWS EKS** (Elastic Kubernetes Service). This project demonstrates how to embed security at every phase of the software delivery lifecycle — from source code to production deployment.

---

## 📌 Table of Contents

1. [Project Overview](#-project-overview)
2. [Project Architecture & Flow](#-project-architecture--flow)
3. [Directory Structure](#-directory-structure)
4. [CI/CD Pipeline Stages](#-cicd-pipeline-stages)
5. [Tools Used](#-tools-used)
6. [Kubernetes Deployment](#-kubernetes-deployment)
7. [Terraform Infrastructure (EKS)](#-terraform-infrastructure-eks)
8. [DevSecOps Terminology Glossary](#-devsecops-terminology-glossary)
9. [Prerequisites](#-prerequisites)
10. [Getting Started](#-getting-started)

---

## 🎯 Project Overview

This project is a **Hotstar-inspired OTT streaming platform UI** built with **React.js**. It fetches movie/show data from **The Movie Database (TMDB) API** and presents it with a responsive, Netflix/Hotstar-style layout.

The application is wrapped in a complete **DevSecOps pipeline** that:

- Performs **Static Application Security Testing (SAST)** using SonarQube
- Scans third-party **dependencies for known CVEs** using OWASP Dependency-Check
- Scans the **filesystem and Docker image** for vulnerabilities using Trivy
- Builds and pushes a **Docker image** to Docker Hub
- Deploys to a **Kubernetes cluster on AWS EKS** via Kubernetes manifests
- Provisions the **EKS cluster infrastructure** using Terraform (Infrastructure as Code)

**Key purpose:** Demonstrate how "shift-left" security practices are integrated seamlessly into a modern cloud-native application delivery workflow.

---

## 🏗️ Project Architecture & Flow

```
Developer Push
      │
      ▼
┌─────────────────────────────────────────────────────────┐
│                     JENKINS CI/CD                       │
│                                                         │
│  1. Git Checkout                                        │
│         │                                               │
│         ▼                                               │
│  2. SonarQube Analysis  ──► SonarQube Server            │
│     (SAST - Code Quality & Security)                    │
│         │                                               │
│         ▼                                               │
│  3. npm install                                         │
│     (Install Node.js dependencies)                      │
│         │                                               │
│         ▼                                               │
│  4. OWASP Dependency-Check                              │
│     (SCA - Scan dependencies for CVEs)                  │
│         │                                               │
│         ▼                                               │
│  5. Trivy Filesystem Scan                               │
│     (Scan source files & packages)                      │
│         │                                               │
│         ▼                                               │
│  6. Docker Build & Push ──► Docker Hub Registry         │
│     (Containerise the React app)                        │
│         │                                               │
│         ▼                                               │
│  7. Trivy Image Scan                                    │
│     (Scan container image for CVEs)                     │
│         │                                               │
│         ▼                                               │
│  8. Deploy to Kubernetes (AWS EKS)                      │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
              ┌───────────────────────┐
              │     AWS EKS Cluster   │
              │  (Provisioned by      │
              │   Terraform)          │
              │                       │
              │  ┌─────────────────┐  │
              │  │  hotstar Pod(s) │  │
              │  │  port 3000      │  │
              │  └────────┬────────┘  │
              │           │           │
              │  ┌────────▼────────┐  │
              │  │ NodePort Service│  │
              │  │ port 31000      │  │
              └──└─────────────────┘──┘
                          │
                          ▼
                    End Users 🌐
```

### Infrastructure Provisioning Flow (Terraform)

```
terraform init  →  terraform plan  →  terraform apply
      │                                      │
      ▼                                      ▼
 S3 Backend                         AWS Resources Created:
 (remote state)                     - VPC (default)
                                    - IAM Roles & Policies
                                    - EKS Control Plane
                                    - Managed Node Group
                                      (t3.medium)
```

---

## 📁 Directory Structure

```
Devsecops-Hotstar-Clone/
│
├── src/                          # React.js application source code
│   ├── App.js                    # Root application component
│   ├── index.js                  # React entry point
│   ├── request.jsx               # TMDB API request configurations
│   ├── tmdbAxiosInstance.js      # Axios instance for TMDB API
│   └── components/               # Reusable UI components
│       ├── Nav.jsx               # Top navigation bar
│       ├── NavBar.jsx            # Navigation bar with search
│       ├── Banner.jsx            # Hero banner / featured content
│       ├── Row.jsx               # Movie/show row component
│       ├── Genre.jsx             # Genre filter component
│       ├── Language.jsx          # Language filter component
│       ├── Platforms.jsx         # Supported platforms section
│       ├── Logo.jsx              # App logo component
│       └── Footer.jsx            # Footer component
│
├── public/
│   └── index.html                # HTML entry point
│
├── K8S/                          # Kubernetes manifests
│   ├── deployment.yml            # Kubernetes Deployment definition
│   ├── service.yml               # Kubernetes Service (NodePort)
│   └── Jenkinsfile               # Jenkins pipeline for K8S deployment
│
├── EKS_infra/                    # Terraform IaC for AWS EKS
│   ├── main.tf                   # EKS cluster, node group, IAM, S3
│   ├── provider.tf               # AWS provider & Terraform version config
│   └── backend.tf                # Remote state backend (S3)
│
├── Dockerfile                    # Docker image build instructions
├── Jenkinsfile                   # Main CI/CD pipeline definition
├── package.json                  # Node.js project manifest
└── README.md                     # Project documentation (this file)
```

---

## 🔄 CI/CD Pipeline Stages

The main `Jenkinsfile` defines the following pipeline stages:

### Stage 1 — Git Checkout
```groovy
git branch: 'main', url: 'https://github.com/...'
```
Jenkins pulls the latest code from the GitHub repository. This is the starting point of every pipeline run.

---

### Stage 2 — SonarQube Analysis (SAST)
```groovy
withSonarQubeEnv('SonarQube') {
    sh '$SCANNER_HOME/bin/sonar-scanner ...'
}
```
**Static Application Security Testing (SAST)** — SonarQube scans the source code for:
- Security vulnerabilities (e.g., XSS, injection flaws)
- Code smells and maintainability issues
- Code duplication
- Unit test coverage gaps

The scan generates a detailed report on the SonarQube dashboard.

---

### Stage 3 — Install Dependencies
```bash
npm install
```
Installs all Node.js packages defined in `package.json`. This step is required before running dependency vulnerability scans.

---

### Stage 4 — OWASP Dependency-Check (SCA)
```groovy
dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'DC'
dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
```
**Software Composition Analysis (SCA)** — OWASP Dependency-Check inspects all third-party libraries used by the project and cross-references them against the **National Vulnerability Database (NVD)** and other CVE databases. It generates an XML/HTML report that Jenkins publishes as a build artifact.

---

### Stage 5 — Trivy Filesystem Scan
```bash
trivy fs --severity HIGH,CRITICAL ./ --format table --output trivy-fs-report.txt
```
Trivy scans the entire project **filesystem** (including `node_modules`) for:
- Known vulnerabilities in OS packages and language libraries
- Misconfigurations in Dockerfiles and IaC files
- Secrets accidentally committed to the codebase

Output is saved as `trivy-fs-report.txt`.

---

### Stage 6 — Docker Build & Push
```bash
docker build -t hotstar .
docker tag hotstar vaibhavcheif/hotstardevsecops:latest
docker push vaibhavcheif/hotstardevsecops:latest
```
The application is **containerised** using the `Dockerfile`:
- Uses `node:alpine` as the base image (lightweight)
- Copies source code, installs dependencies, exposes port `3000`
- The final image is tagged and pushed to **Docker Hub**

---

### Stage 7 — Trivy Image Scan
```bash
trivy image --severity HIGH,CRITICAL vaibhavcheif/hotstardevsecops:latest --format table --output trivy-image-report.txt
```
After the Docker image is built and pushed, Trivy scans the **container image layers** for vulnerabilities in OS packages and application dependencies. This ensures the image shipped to production is free of HIGH and CRITICAL CVEs.

---

### Stage 8 — Deploy to Kubernetes
The application is deployed to AWS EKS using Kubernetes manifests:

**Deployment** (`K8S/deployment.yml`):
- Creates a `hotstar-deployment` with **1 replica**
- Uses the `vaibhavcheif/hotstardevsecops:latest` image
- Exposes container port `3000`

**Service** (`K8S/service.yml`):
- Creates a `hotstar-service` of type **NodePort**
- Maps internal port `3000` → external NodePort `31000`
- Accessible at `http://<node-ip>:31000`

---

## ☸️ Kubernetes Deployment

### Apply Manifests
```bash
# Configure kubectl for EKS
aws eks update-kubeconfig --region ap-south-1 --name dev-eks-cluster

# Deploy the application
kubectl apply -f K8S/deployment.yml
kubectl apply -f K8S/service.yml

# Verify deployment
kubectl get pods
kubectl get svc hotstar-service
```

### Access the Application
Once deployed, the application is accessible at:
```
http://<EKS-Node-Public-IP>:31000
```

### Key Kubernetes Resources

| Resource | Name | Type | Details |
|---|---|---|---|
| Deployment | `hotstar-deployment` | `apps/v1` | 1 replica, port 3000 |
| Service | `hotstar-service` | `NodePort` | NodePort 31000 → 3000 |

---

## 🌍 Terraform Infrastructure (EKS)

The `EKS_infra/` directory contains Terraform code to provision the AWS EKS cluster.

### Resources Created

| Resource | Name | Purpose |
|---|---|---|
| IAM Role | `dev-eks-cluster-role` | EKS control plane permissions |
| IAM Role | `dev-eks-node-role` | Worker node EC2 permissions |
| EKS Cluster | `dev-eks-cluster` | Kubernetes control plane (v1.35) |
| Node Group | `dev-node-group` | Managed worker nodes (t3.medium) |
| S3 Bucket | `eks-terraform-state-vaibh-2026` | Terraform remote state storage |

### Terraform Commands
```bash
cd EKS_infra/

# Initialise (downloads providers, configures S3 backend)
terraform init

# Preview infrastructure changes
terraform plan

# Provision the infrastructure
terraform apply

# Destroy the infrastructure (to avoid costs)
terraform destroy
```

### Backend Configuration
Terraform state is stored remotely in an S3 bucket to enable team collaboration and prevent state file conflicts:
```hcl
# backend.tf
backend "s3" {
  bucket = "eks-devsecops-hotstarclone"
  key    = "eks/terraform.tfstate"
  region = "ap-south-1"
}
```

---

## 📚 DevSecOps Terminology Glossary

### Core DevSecOps Concepts

| Term | Definition |
|---|---|
| **DevSecOps** | A culture and practice that integrates security ("Sec") into every stage of the DevOps lifecycle — development, testing, and deployment — rather than treating it as an afterthought. |
| **Shift-Left Security** | Moving security testing and validation earlier in the SDLC (closer to development), reducing the cost and effort of fixing vulnerabilities discovered late. |
| **CI/CD** | **Continuous Integration / Continuous Delivery** — an automated process where code changes are automatically built, tested, and deployed to production. |
| **Pipeline as Code** | Defining CI/CD pipelines in version-controlled files (e.g., `Jenkinsfile`) so the pipeline itself is auditable and reproducible. |
| **IaC (Infrastructure as Code)** | Managing and provisioning infrastructure through machine-readable definition files (Terraform) rather than manual processes. |

### Security Testing Types

| Term | Definition |
|---|---|
| **SAST** (Static Application Security Testing) | Analysis of source code for security vulnerabilities *without* executing the application. Performed by SonarQube in this project. |
| **SCA** (Software Composition Analysis) | Scanning third-party and open-source components for known vulnerabilities (CVEs). Performed by OWASP Dependency-Check. |
| **Container Security Scanning** | Scanning Docker images for OS and library vulnerabilities before deployment. Performed by Trivy. |
| **CVE** (Common Vulnerabilities and Exposures) | A publicly disclosed cybersecurity vulnerability identified with a unique ID (e.g., CVE-2021-44228). |
| **NVD** (National Vulnerability Database) | The U.S. government's repository of CVE data, maintained by NIST, used by OWASP Dependency-Check. |

### Tools Used in This Project

| Tool | Category | Purpose in This Project |
|---|---|---|
| **Jenkins** | CI/CD Automation | Orchestrates all pipeline stages from code checkout to deployment |
| **SonarQube** | SAST / Code Quality | Scans source code for bugs, vulnerabilities, and code smells |
| **OWASP Dependency-Check** | SCA | Identifies vulnerable third-party npm packages |
| **Trivy** | Vulnerability Scanner | Scans filesystem and Docker images for HIGH/CRITICAL CVEs |
| **Docker** | Containerisation | Packages the React app into a portable, reproducible container image |
| **Docker Hub** | Container Registry | Stores and distributes the built Docker images |
| **Kubernetes (K8S)** | Container Orchestration | Manages deployment, scaling, and availability of containers |
| **AWS EKS** | Managed Kubernetes | AWS-managed Kubernetes control plane for running workloads |
| **Terraform** | Infrastructure as Code | Provisions AWS EKS cluster, IAM roles, and node groups |
| **AWS S3** | Remote State / Storage | Stores Terraform state file remotely for team collaboration |
| **Node.js / npm** | Runtime / Package Manager | Runs the React development server and manages JS dependencies |
| **React.js** | Frontend Framework | Builds the Hotstar clone UI with reusable components |
| **TMDB API** | External API | Provides movie and TV show metadata for the application |
| **Axios** | HTTP Client | Makes API requests from React to the TMDB REST API |

### Infrastructure & Kubernetes Terms

| Term | Definition |
|---|---|
| **Pod** | The smallest deployable unit in Kubernetes; wraps one or more containers. |
| **Deployment** | A Kubernetes resource that declaratively manages a set of replica Pods and handles rolling updates. |
| **Service** | A Kubernetes resource that exposes Pods to network traffic, providing a stable endpoint. |
| **NodePort** | A Service type that exposes the application on a static port (31000) across every node in the cluster. |
| **Node Group** | A group of EC2 instances (worker nodes) that run containerised workloads inside an EKS cluster. |
| **IAM Role** | An AWS Identity and Access Management role that grants specific permissions to AWS services (e.g., EKS, EC2). |
| **Remote Backend** | Terraform configuration that stores `.tfstate` in a shared location (S3) rather than on a local machine. |
| **Container Registry** | A repository for storing and versioning Docker images (Docker Hub in this project). |

---

## ✅ Prerequisites

Before running this project, ensure the following tools are installed and configured:

| Tool | Version | Purpose |
|---|---|---|
| Node.js | ≥ 16.x | Run React dev server and build |
| npm | ≥ 8.x | Package management |
| Docker | ≥ 20.x | Build and run containers |
| Jenkins | LTS | CI/CD pipeline orchestration |
| Java (JDK) | 11 or 17 | Required by Jenkins and SonarQube |
| SonarQube | ≥ 9.x | SAST code analysis server |
| OWASP Dependency-Check | ≥ 8.x | Dependency CVE scanning (Jenkins plugin) |
| Trivy | ≥ 0.45.x | Filesystem and image scanning |
| kubectl | ≥ 1.27 | Kubernetes CLI |
| Terraform | ≥ 1.4.0 | Infrastructure provisioning |
| AWS CLI | ≥ 2.x | AWS resource management |

### Jenkins Plugins Required
- Git Plugin
- NodeJS Plugin
- SonarQube Scanner Plugin
- OWASP Dependency-Check Plugin
- Docker Pipeline Plugin
- Kubernetes CLI Plugin

---

## 🚀 Getting Started

### 1. Clone the Repository
```bash
git clone https://github.com/vaibhavcheif/Devsecops-Hotstar-Clone.git
cd Devsecops-Hotstar-Clone
```

### 2. Run Locally (Development)
```bash
# Install dependencies
npm install

# Start the development server
npm start
# App available at http://localhost:3000
```

### 3. Build the Docker Image
```bash
docker build -t hotstardevsecops:latest .
docker run -d -p 3000:3000 hotstardevsecops:latest
# App available at http://localhost:3000
```

### 4. Provision EKS Infrastructure (Terraform)
```bash
cd EKS_infra/
terraform init
terraform plan
terraform apply
```

### 5. Deploy to Kubernetes
```bash
# Update kubeconfig for EKS
aws eks update-kubeconfig --region ap-south-1 --name dev-eks-cluster

# Apply manifests
kubectl apply -f K8S/deployment.yml
kubectl apply -f K8S/service.yml
```

### 6. Configure Jenkins Pipeline
1. Create a **New Pipeline** job in Jenkins
2. Point it to this repository's `Jenkinsfile`
3. Configure the following Jenkins credentials/tools:
   - `jdk` — JDK tool installation
   - `node` — NodeJS tool installation
   - `sonar-scanner` — SonarQube Scanner tool
   - `SonarQube` — SonarQube server environment
   - `DC` — OWASP Dependency-Check installation
   - Docker Hub credentials (for image push)
4. Trigger the pipeline — all stages run automatically

---

## 🔐 Security Summary

This project implements **defence-in-depth** across all pipeline stages:

| Stage | Security Control | Severity Filter |
|---|---|---|
| Source code | SonarQube SAST | Bugs, Vulnerabilities, Code Smells |
| Dependencies | OWASP Dependency-Check | All CVE severities reported |
| Filesystem | Trivy FS Scan | HIGH, CRITICAL only |
| Container Image | Trivy Image Scan | HIGH, CRITICAL only |
| Infrastructure | Terraform IaC | Least-privilege IAM roles |
| Secrets | `.gitignore` | API keys excluded from version control |

---

## 📄 License

This project is intended for **educational and demonstration purposes** only. The Hotstar name, logo, and branding are trademarks of The Walt Disney Company. This clone is not affiliated with or endorsed by Hotstar/Disney+ Hotstar.
