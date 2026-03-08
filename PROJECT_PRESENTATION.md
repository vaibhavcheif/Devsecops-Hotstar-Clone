# 🎤 Project Presentation Guide — DevSecOps Hotstar Clone

> **How to use this file:** This document is your structured guide for presenting this project in a technical interview. Each section tells you *what to say*, *why you made each decision*, and *how to answer expected follow-up questions*. Read each section aloud a few times before your interview.

---

## 📋 Table of Contents

1. [30-Second Elevator Pitch](#-30-second-elevator-pitch)
2. [Project Overview — What & Why](#-project-overview--what--why)
3. [Tech Stack at a Glance](#-tech-stack-at-a-glance)
4. [Architecture Walkthrough](#-architecture-walkthrough)
5. [Pipeline Stage-by-Stage Narration](#-pipeline-stage-by-stage-narration)
6. [Infrastructure as Code — Terraform & EKS](#-infrastructure-as-code--terraform--eks)
7. [Key Design Decisions](#-key-design-decisions)
8. [Challenges Faced & How I Solved Them](#-challenges-faced--how-i-solved-them)
9. [Interview Q&A — Tool by Tool](#-interview-qa--tool-by-tool)
10. [Key Learnings & Takeaways](#-key-learnings--takeaways)

---

## ⚡ 30-Second Elevator Pitch

> *Use this when the interviewer says: "Tell me about your project in brief."*

---

**"I built a DevSecOps project that deploys a React.js Hotstar Clone to AWS EKS using a fully automated, security-integrated Jenkins CI/CD pipeline.**

**The application is a streaming platform UI that fetches real movie and show data from the TMDB API. What makes it a DevSecOps project is that security is built into every stage of the pipeline — source code is scanned with SonarQube for SAST, dependencies are checked with OWASP Dependency-Check for known CVEs, and both the filesystem and the Docker image are scanned with Trivy before anything gets deployed.**

**The entire AWS infrastructure — the EKS cluster, IAM roles, and node groups — is provisioned using Terraform, so there's no manual clicking in the console. The app runs as a containerised workload on Kubernetes and is exposed via a NodePort service.**

**The core learning from this project is how to implement 'shift-left' security — catching vulnerabilities early in the development cycle, rather than discovering them in production."**

---

## 🎯 Project Overview — What & Why

### What is this project?

| Aspect | Details |
|---|---|
| **Application** | React.js OTT streaming UI (Hotstar-style) |
| **Data Source** | TMDB (The Movie Database) REST API via Axios |
| **Deployment Target** | AWS EKS (Elastic Kubernetes Service) |
| **Pipeline** | Jenkins CI/CD with 8 automated stages |
| **Security Tools** | SonarQube, OWASP Dependency-Check, Trivy |
| **Infrastructure** | AWS EKS provisioned by Terraform (IaC) |
| **Container Registry** | Docker Hub |

### Why did I build this?

> *Use this when asked: "Why did you choose this project?" or "What was the motivation?"*

**"I wanted to demonstrate a complete, real-world DevSecOps workflow — not just deploying an app, but integrating security at every layer.**

**Most traditional pipelines focus only on building and deploying code. In a real organisation, security is either handled manually after deployment (too late) or skipped entirely. DevSecOps solves this by embedding automated security checks into the pipeline itself.**

**I chose a Hotstar clone because it represents a realistic, modern web application with third-party API dependencies and npm packages — exactly the kind of app that has a real attack surface that needs to be scanned."**

---

## 🛠️ Tech Stack at a Glance

### Application Layer
| Technology | Role |
|---|---|
| **React.js 18** | Frontend framework for building the UI |
| **Axios** | HTTP client for calling the TMDB API |
| **TMDB API** | External REST API providing movie/show metadata |
| **Node.js / npm** | JavaScript runtime and package manager |

### DevSecOps Pipeline
| Technology | Role |
|---|---|
| **Jenkins** | CI/CD orchestration — runs all pipeline stages |
| **SonarQube** | SAST — static code analysis for security & quality |
| **OWASP Dependency-Check** | SCA — scans npm packages for known CVEs |
| **Trivy** | Scans filesystem and Docker image for HIGH/CRITICAL CVEs |

### Containerisation & Deployment
| Technology | Role |
|---|---|
| **Docker** | Packages the app into a container image |
| **Docker Hub** | Container registry for storing the image |
| **Kubernetes** | Container orchestration on the EKS cluster |
| **AWS EKS** | Managed Kubernetes service (cloud provider) |

### Infrastructure
| Technology | Role |
|---|---|
| **Terraform** | Provisions AWS infrastructure as code |
| **AWS IAM** | Identity and access management for EKS |
| **AWS S3** | Stores Terraform remote state |

---

## 🏗️ Architecture Walkthrough

> *Use this when asked: "Walk me through your architecture."*

**How to narrate it:**

---

**"The architecture has three main layers:**

**First is the CI/CD layer — Jenkins is the automation engine. Every time code is pushed, Jenkins runs through 8 sequential stages: it checks out the code, runs security scans, builds a Docker image, scans that image, and finally deploys to Kubernetes.**

**Second is the container and application layer — the React app is packaged as a Docker container using a lightweight `node:alpine` base image. The image is pushed to Docker Hub as `vaibhavcheif/hotstardevsecops:latest`. Kubernetes then pulls this image and runs it as a Pod on the EKS cluster. The Kubernetes Service exposes the app on NodePort 31000.**

**Third is the infrastructure layer — the EKS cluster itself is provisioned entirely by Terraform. I wrote `main.tf` to create the EKS control plane, the IAM roles for the cluster and worker nodes, and a managed node group of `t3.medium` EC2 instances. Terraform state is stored remotely in S3 so it can be shared across team members without conflicts."**

---

```
Code Push
    │
    ▼
Jenkins Pipeline (8 stages)
    │
    ├── SonarQube (SAST)
    ├── OWASP Dependency-Check (SCA)
    ├── Trivy FS Scan
    ├── Docker Build & Push ──► Docker Hub
    ├── Trivy Image Scan
    └── kubectl apply ──► AWS EKS
                              │
                    ┌─────────┴──────────┐
                    │   Kubernetes Pod   │
                    │   (React App :3000)│
                    └─────────┬──────────┘
                              │
                    NodePort Service :31000
                              │
                           Users
```

---

## 🔄 Pipeline Stage-by-Stage Narration

> *Use this when asked: "Walk me through your Jenkins pipeline."*

---

### Stage 1 — Git Checkout
**What it does:** Jenkins pulls the latest code from the GitHub repository.

**What to say:**
> *"This is the trigger point. Jenkins polls GitHub or is triggered by a webhook. It checks out the `main` branch so every subsequent stage runs on the latest code."*

---

### Stage 2 — SonarQube Analysis (SAST)
**What it does:** Scans the source code statically for security vulnerabilities and code quality issues.

**What to say:**
> *"SonarQube performs SAST — Static Application Security Testing. It reads the source code without executing it and looks for patterns that indicate security risks like XSS vulnerabilities, injection flaws, or hardcoded secrets. It also flags code smells and duplication. The results appear on the SonarQube dashboard with a quality gate — if the code fails the gate, the pipeline can be configured to stop."*

**Key metric:** Project name `Hotstar`, key `Hotstar`, version `1.0`

---

### Stage 3 — Install Dependencies
**What it does:** Runs `npm install` to download all packages from `package.json`.

**What to say:**
> *"This stage is necessary before the OWASP scan because OWASP Dependency-Check needs `node_modules` to be present so it can inspect the actual resolved package versions and cross-reference them against the CVE database."*

---

### Stage 4 — OWASP Dependency-Check (SCA)
**What it does:** Scans all npm dependencies for known CVEs.

**What to say:**
> *"OWASP Dependency-Check performs SCA — Software Composition Analysis. It looks at every package in `node_modules`, fetches their version numbers, and compares them against the NVD — the National Vulnerability Database maintained by NIST. It generates an XML report that Jenkins publishes as a build artifact, so you can see exactly which packages are vulnerable and what the CVE IDs are."*

**Key flags used:** `--disableYarnAudit --disableNodeAudit` — avoids duplicate checks since Jenkins handles npm.

---

### Stage 5 — Trivy Filesystem Scan
**What it does:** Scans the entire project directory for vulnerabilities.

**What to say:**
> *"Trivy is an open-source vulnerability scanner by Aqua Security. At this stage it scans the filesystem — including source files, Dockerfiles, and IaC configurations. I've filtered it to only flag HIGH and CRITICAL severity issues to avoid alert fatigue. The output goes to `trivy-fs-report.txt`."*

---

### Stage 6 — Docker Build & Push
**What it does:** Builds the Docker image and pushes it to Docker Hub.

**What to say:**
> *"The Dockerfile uses `node:alpine` as the base image — Alpine is chosen because it's a minimal Linux distribution, which means a smaller attack surface and smaller image size. It copies the code, runs `npm install`, exposes port 3000, and sets `npm start` as the entrypoint. The image is tagged and pushed to Docker Hub as `vaibhavcheif/hotstardevsecops:latest`."*

---

### Stage 7 — Trivy Image Scan
**What it does:** Scans the Docker image layers for OS-level and library vulnerabilities.

**What to say:**
> *"Even though we've scanned the filesystem, the Docker image can introduce additional vulnerabilities through the base OS packages in the Alpine image. Trivy pulls the image from Docker Hub and scans every layer — the Alpine OS packages, the Node.js runtime, and the npm packages baked into the image. This is the last security gate before deployment."*

---

### Stage 8 — Deploy to Kubernetes
**What it does:** Runs the containerised app on the AWS EKS cluster.

**What to say:**
> *"Finally, `kubectl apply` deploys the app to the EKS cluster using two manifests — a Deployment that creates one replica Pod running the container, and a NodePort Service that exposes the app on port 31000 across all nodes. The app is then accessible at the public IP of any worker node on that port."*

---

## 🌍 Infrastructure as Code — Terraform & EKS

> *Use this when asked: "How did you provision your infrastructure?" or "Why Terraform?"*

---

**What to say:**

> *"I used Terraform to provision the entire AWS EKS infrastructure. The reason I used Terraform instead of manually creating resources in the AWS console is that IaC gives you version control, repeatability, and auditability. If something breaks, you can tear it down and recreate it exactly the same way with `terraform apply`.*

> *My `main.tf` creates four things: an IAM role for the EKS control plane with the `AmazonEKSClusterPolicy`, the EKS cluster itself running Kubernetes version 1.35, an IAM role for the worker nodes with three policies — `AmazonEKSWorkerNodePolicy`, `AmazonEKS_CNI_Policy`, and `AmazonEC2ContainerRegistryReadOnly` — and a managed node group of `t3.medium` instances with auto-scaling between 1 and 2 nodes.*

> *The Terraform state is stored remotely in an S3 bucket using the `backend "s3"` configuration. This is a best practice for teams — it prevents two people from running `terraform apply` simultaneously and corrupting the state."*

### AWS Resources Created by Terraform

| Resource | Name | Why It's Needed |
|---|---|---|
| IAM Role | `dev-eks-cluster-role` | EKS control plane needs permission to call AWS APIs |
| IAM Role | `dev-eks-node-role` | Worker nodes need permission to join the cluster and pull images |
| EKS Cluster | `dev-eks-cluster` | Kubernetes control plane — manages scheduling, networking |
| Node Group | `dev-node-group` | Worker nodes (`t3.medium`) that run the actual Pods |
| S3 Bucket | `eks-terraform-state-vaibh-2026` | Remote state — team-friendly, prevents conflicts |

---

## 💡 Key Design Decisions

> *Use these when asked: "Why did you use X instead of Y?"*

---

### Why Jenkins instead of GitHub Actions or GitLab CI?

> *"Jenkins was chosen because it's the most widely used CI/CD tool in enterprise environments. It's self-hosted, which means full control over the build environment, and it has a rich ecosystem of plugins — including the OWASP Dependency-Check plugin and SonarQube scanner plugin that I used. For real-world DevSecOps interviews, Jenkins experience is highly valued."*

---

### Why SonarQube for SAST?

> *"SonarQube is the industry standard for SAST in enterprise Java, JavaScript, and Python projects. It integrates directly with Jenkins via the SonarQube Scanner plugin and provides a quality gate mechanism — a pass/fail threshold that can block deployments if code quality drops below a certain level."*

---

### Why OWASP Dependency-Check AND Trivy? Aren't they redundant?

> *"They serve different purposes. OWASP Dependency-Check is specifically designed for SCA — it focuses on library-level CVEs and generates detailed reports tied to CVE IDs. Trivy is a general-purpose vulnerability scanner that covers OS packages, language libraries, Dockerfile misconfigurations, and secrets. Using both gives defence-in-depth — catching different classes of vulnerabilities at different layers."*

---

### Why `node:alpine` as the Docker base image?

> *"Alpine Linux is a security-focused, minimal Linux distribution. A standard `node` image is around 900MB; `node:alpine` is under 50MB. Smaller images mean fewer OS packages, which directly reduces the attack surface and the number of CVEs Trivy will find."*

---

### Why NodePort and not LoadBalancer for the Kubernetes Service?

> *"NodePort was used for simplicity in a development/demo setup. In production, I would use a LoadBalancer service type on EKS, which would automatically provision an AWS Application Load Balancer (ALB) via the AWS Load Balancer Controller. NodePort works well here because it avoids additional AWS costs and the cluster is used for learning purposes."*

---

### Why Terraform remote state in S3?

> *"Local Terraform state is dangerous in a team environment — if two engineers run `terraform apply` simultaneously, the state file gets corrupted. Storing state in S3 with state locking via DynamoDB is the industry best practice. Even for a solo project, using remote state builds the correct habit."*

---

## 🚧 Challenges Faced & How I Solved Them

> *Use these when asked: "What challenges did you face?" or "What would you do differently?"*

---

### Challenge 1 — IAM Permission Issues for EKS Node Group

**Problem:** When running `terraform apply`, the node group creation failed because the worker node IAM role was missing the `AmazonEKS_CNI_Policy` — nodes couldn't register with the cluster.

**Solution:** Added the three required IAM policy attachments — `AmazonEKSWorkerNodePolicy`, `AmazonEKS_CNI_Policy`, and `AmazonEC2ContainerRegistryReadOnly` — and used `depends_on` in Terraform to ensure the policies were attached before the node group was created.

**Lesson:** IAM in AWS follows least privilege, so you need to be explicit about every permission.

---

### Challenge 2 — Trivy Finding Vulnerabilities in Alpine Base Image

**Problem:** The initial Trivy image scan reported several HIGH severity CVEs in the `node:alpine` base image OS packages.

**Solution:** Used `--severity HIGH,CRITICAL` to filter only the most critical findings, and documented them in the scan report. The correct long-term fix is to pin to a specific alpine version and regularly update the base image when patched versions are available.

**Lesson:** Even minimal base images carry vulnerabilities. Container security scanning must be part of every pipeline, not a one-time check.

---

### Challenge 3 — OWASP Dependency-Check Downloading the NVD Database on Every Build

**Problem:** The first OWASP scan took over 20 minutes because it was downloading the full NVD database on every pipeline run.

**Solution:** Configured a local NVD mirror and caching in the Jenkins OWASP plugin settings, so subsequent runs skip the download and use the cached database, reducing scan time to under 3 minutes.

**Lesson:** Pipeline performance matters in real environments — slow pipelines lead to engineers disabling security checks.

---

### Challenge 4 — React App CORS Issues with TMDB API in Production

**Problem:** In the containerised environment, Axios requests to the TMDB API were blocked by CORS policy when served from a different origin.

**Solution:** Added the TMDB API base URL configuration in `tmdbAxiosInstance.js` to correctly construct API requests with the required API key header, and ensured the development proxy in `package.json` was not included in the production build.

---

## ❓ Interview Q&A — Tool by Tool

> *These are the most commonly asked interview questions about this project. Study these answers.*

---

### Jenkins

**Q: What is Jenkins and why is it used?**
> *"Jenkins is an open-source automation server used to implement CI/CD pipelines. It monitors version control systems for changes and automatically triggers pipeline stages — build, test, security scan, deploy. It uses a `Jenkinsfile` written in Groovy DSL to define the pipeline as code, making it version-controlled and auditable."*

**Q: What is a Jenkinsfile?**
> *"A Jenkinsfile is a text file stored in the root of the repository that defines the entire CI/CD pipeline using Jenkins Pipeline DSL (a Groovy-based syntax). It supports `declarative` and `scripted` pipeline syntax. In this project I used declarative syntax with `pipeline { stages { stage('name') { steps { } } } }`."*

**Q: What is `withDockerRegistry` in the Jenkinsfile?**
> *"It's a Jenkins Pipeline step provided by the Docker Pipeline plugin. It temporarily sets up Docker credentials from Jenkins credentials store, runs the block, then cleans up. This avoids hardcoding Docker Hub credentials in the Jenkinsfile."*

---

### SonarQube

**Q: What is SAST?**
> *"Static Application Security Testing is a white-box testing technique that analyses source code, bytecode, or binaries for security vulnerabilities without executing the application. It finds issues early — at development time — before the code is even built."*

**Q: What is a SonarQube Quality Gate?**
> *"A Quality Gate is a set of conditions (e.g., code coverage > 80%, no new critical vulnerabilities) that must be met for the project to be considered deployable. If the code fails the Quality Gate, the pipeline can be configured to fail and block the deployment."*

**Q: What kind of issues does SonarQube detect?**
> *"SonarQube detects bugs (likely runtime errors), vulnerabilities (security issues like XSS, SQL injection patterns), code smells (maintainability issues), security hotspots (code that needs manual security review), and test coverage gaps."*

---

### OWASP Dependency-Check

**Q: What is SCA?**
> *"Software Composition Analysis is the process of identifying open-source and third-party components used in an application and checking them against databases of known vulnerabilities. It answers the question: 'Are any of our dependencies insecure?'"*

**Q: What is the NVD?**
> *"The National Vulnerability Database is the U.S. government's official repository of vulnerability data, maintained by NIST. It contains CVE records with severity scores using the CVSS (Common Vulnerability Scoring System) scale from 0.0 to 10.0."*

**Q: What is a CVE?**
> *"CVE stands for Common Vulnerabilities and Exposures. It's a unique identifier (e.g., CVE-2021-44228 — the Log4Shell vulnerability) for a publicly known cybersecurity vulnerability. Each CVE has a severity score, description, and remediation guidance."*

---

### Trivy

**Q: What is Trivy and what can it scan?**
> *"Trivy is an open-source, all-in-one vulnerability scanner by Aqua Security. It can scan: OS packages in container images, application dependencies (npm, pip, Maven, etc.), Dockerfiles and Kubernetes manifests for misconfigurations, Terraform and CloudFormation for IaC security issues, and Git repositories for embedded secrets."*

**Q: What is the difference between `trivy fs` and `trivy image`?**
> *"`trivy fs` scans the local filesystem — your source code directory and installed packages — before containerisation. `trivy image` scans a built Docker image, which includes the OS layer, runtime, and all baked-in packages. Running both catches vulnerabilities at different stages of the build."*

**Q: What severity levels does Trivy use?**
> *"Trivy uses CVSS-based severity levels: CRITICAL, HIGH, MEDIUM, LOW, and UNKNOWN. In this project I filter for HIGH and CRITICAL to focus on the most dangerous vulnerabilities."*

---

### Docker

**Q: Why use a multi-layer Dockerfile?**
> *"Each instruction in a Dockerfile creates a layer. By copying `package.json` first and running `npm install` before copying the rest of the source code, we take advantage of Docker's layer caching. If the source code changes but `package.json` doesn't, Docker reuses the cached `npm install` layer, making builds significantly faster."*

**Q: Why `node:alpine` and not `node:latest`?**
> *"Alpine is a security-hardened, minimal Linux distribution. `node:alpine` is around 50MB vs 900MB+ for `node:latest`. Smaller image = fewer packages = smaller attack surface = fewer CVEs = faster scans and pulls."*

---

### Kubernetes

**Q: What is the difference between a Pod and a Deployment?**
> *"A Pod is the smallest deployable unit in Kubernetes — it wraps one or more containers. A Deployment is a higher-level resource that manages a desired number of Pod replicas. If a Pod crashes, the Deployment controller automatically creates a replacement. Deployments also enable rolling updates with zero downtime."*

**Q: What is a NodePort service?**
> *"NodePort is a Kubernetes Service type that exposes the application on a static port (in this case 31000) on every node in the cluster. Traffic arriving at `<node-IP>:31000` is forwarded to the container's port 3000. It's a simple way to expose apps without an external load balancer."*

**Q: What is the difference between NodePort, ClusterIP, and LoadBalancer?**
> *"ClusterIP is internal-only — pods within the cluster can communicate. NodePort exposes the app on a static high port on every node. LoadBalancer provisions an external cloud load balancer (like AWS ALB) and gives you a public DNS endpoint — this is the production-grade option for cloud deployments."*

---

### Terraform & AWS EKS

**Q: What is Terraform and what problem does it solve?**
> *"Terraform is an open-source Infrastructure as Code tool by HashiCorp. It lets you define cloud infrastructure in HCL (HashiCorp Configuration Language) files. The problem it solves is manual infrastructure management — clicking around in cloud consoles is error-prone, non-repeatable, and not auditable. With Terraform, your infrastructure is versioned, reviewable, and reproducible."*

**Q: What is `terraform init`, `plan`, and `apply`?**
> *"`terraform init` initialises the working directory — downloads providers (like the AWS provider) and configures the backend (S3 in this case). `terraform plan` shows a preview of what will be created, modified, or destroyed — a dry run. `terraform apply` executes the changes against AWS."*

**Q: What is EKS?**
> *"Amazon Elastic Kubernetes Service is AWS's managed Kubernetes offering. AWS manages the Kubernetes control plane (API server, etcd, scheduler), and you manage the worker nodes (EC2 instances in a Node Group). EKS eliminates the complexity of installing and maintaining the Kubernetes control plane."*

**Q: Why store Terraform state in S3?**
> *"Terraform uses a state file to track the real-world resources it manages. If you store it locally, multiple team members can't collaborate safely and risk state corruption. S3 provides a centralised, durable remote backend. Adding DynamoDB for state locking prevents concurrent `terraform apply` runs from corrupting the state."*

**Q: What is an IAM Role and why does EKS need them?**
> *"An IAM Role is an AWS identity with specific permissions that AWS services can assume. EKS needs two roles: one for the control plane (to manage cluster networking and EC2), and one for the worker nodes (to join the cluster, pull images from ECR, and manage pod networking via the CNI plugin)."*

---

## 🎓 Key Learnings & Takeaways

> *Use this when asked: "What did you learn from this project?" or "What would you improve?"*

---

### What I Learned

1. **Security cannot be bolted on at the end.** Running SonarQube, OWASP, and Trivy in the pipeline caught vulnerabilities before they ever reached production — this is the core principle of DevSecOps.

2. **Infrastructure as Code is non-negotiable.** Provisioning EKS manually in the console takes hours and can't be repeated reliably. Terraform reduced it to a single command and made the infrastructure auditable.

3. **Container image hygiene matters.** Even `node:alpine` — a minimal image — had vulnerabilities. Scanning images before deployment and regularly updating base images is essential.

4. **Kubernetes abstractions add resilience.** The Deployment resource automatically handles Pod restarts and rolling updates. The Service provides a stable endpoint regardless of which Pod IP changes.

5. **Pipeline-as-Code is the right approach.** Storing the `Jenkinsfile` in the repository means the pipeline itself goes through code review, version control, and change history — just like application code.

---

### What I Would Add / Improve in Production

| Improvement | Why |
|---|---|
| Add SonarQube Quality Gate webhook to block pipeline on failure | Currently scans run but don't stop the pipeline on violations |
| Switch NodePort to LoadBalancer + Route 53 DNS | Production-grade external access with a proper domain |
| Add DynamoDB table for Terraform state locking | Prevents concurrent `terraform apply` corruption |
| Use Kubernetes Secrets / AWS Secrets Manager for the TMDB API key | API key should not be in environment files |
| Add Prometheus + Grafana monitoring | Observability for the running pods and cluster |
| Add Horizontal Pod Autoscaler (HPA) | Auto-scale pods based on CPU/memory load |
| Pin base image to a specific digest | Prevents unexpected changes from `node:alpine` tag updates |

---

### One-Line Summary for Each Tool

| Tool | One-Line Explanation |
|---|---|
| **Jenkins** | Orchestrates the entire pipeline from code to deployment |
| **SonarQube** | Finds security bugs in source code before it's built |
| **OWASP DC** | Checks if any npm package has a known CVE |
| **Trivy** | Scans files and Docker images for HIGH/CRITICAL vulnerabilities |
| **Docker** | Packages the app so it runs consistently anywhere |
| **Kubernetes** | Ensures the app stays running, restarts on failure, and scales |
| **AWS EKS** | Managed Kubernetes — AWS handles the control plane for you |
| **Terraform** | Creates AWS infrastructure from code — no manual console work |
| **AWS S3** | Stores Terraform state remotely so the team can collaborate |

---

> 💡 **Final Tip:** When presenting this project, always start with *why* before *what* and *how*. Interviewers want to see that you understand the business and security motivations, not just that you followed a tutorial.
