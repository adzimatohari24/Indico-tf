# Indico-tf

Terraform module untuk men-deploy containerized application di AWS menggunakan ECS Fargate, dilengkapi CI/CD pipeline via CodePipeline dan CodeBuild, serta Application Load Balancer sebagai entry point.

---

## Overview

Proyek ini menyediakan infrastruktur as code yang mencakup:

- **ECS Fargate** — menjalankan container tanpa perlu manage EC2
- **Application Load Balancer (ALB)** — mendistribusikan traffic ke ECS service
- **AWS CodeBuild** — build image dari source code GitHub
- **AWS CodePipeline** — orkestrasi CI/CD dari source → build → deploy ke S3
- **CloudWatch Logs** — logging untuk ECS task dan CodeBuild
- **IAM Roles** — least-privilege roles untuk setiap service

Semua resource diorganisir ke dalam modul terpisah sehingga mudah di-reuse dan dikustomisasi per environment.

---

## Architecture

```
Internet
    │
    ▼
┌─────────────────────────────────────────────────────────────────┐
│                     AWS Cloud (ap-southeast-1)                  │
│                                                                 │
│  ┌──────────────┐     ┌───────────────────────────────────┐    │
│  │    GitHub    │     │        VPC (sudah ada)             │    │
│  │  Repository  │     │                                   │    │
│  └──────┬───────┘     │  ┌──────────────────────────────┐ │    │
│         │ webhook     │  │      Public Subnets           │ │    │
│         ▼             │  │      (sudah ada)              │ │    │
│  ┌──────────────┐     │  │                               │ │    │
│  │ CodePipeline │     │  │  ┌──────────┐  ┌──────────┐  │ │    │
│  │              │     │  │  │   ALB    │  │   ECS    │  │ │    │
│  │  Stage 1:    │     │  │  │ (port 80)│─▶│ Fargate  │  │ │    │
│  │   Source     │     │  │  └──────────┘  │  Task    │  │ │    │
│  │              │     │  │               └──────────┘  │ │    │
│  │  Stage 2:    │     │  └──────────────────────────────┘ │    │
│  │   Build ─────┼─────┼──▶  CodeBuild                    │    │
│  │  (CodeBuild) │     │     (build image)                 │    │
│  │              │     │                                   │    │
│  │  Stage 3:    │     │  ┌─────────────────────────────┐  │    │
│  │   Deploy ────┼─────┼──▶  S3 Bucket (artifacts)      │  │    │
│  └──────────────┘     │  └─────────────────────────────┘  │    │
│                       └───────────────────────────────────┘    │
│                                                                 │
│  CloudWatch Logs (/ecs/*, /codebuild/*)                        │
└─────────────────────────────────────────────────────────────────┘
```

### Struktur Modul

```
Indico-tf/
├── main.tf                    # Root module, memanggil semua sub-modul
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── modules/
│   ├── alb/                   # Application Load Balancer
│   ├── ecs/                   # ECS Cluster
│   ├── codebuild/             # CodeBuild Project
│   └── codepipeline/          # CodePipeline
└── examples/
    └── complete/              # Example
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        └── terraform.tfvars.example
```

---

## Asumsi


1. VPC sudah ada

2. Subnet sudah ada

3. GitHub sebagai source

4. Container image dapat diakses ECS

5. HTTPS opsional — ALB saat ini hanya listen di port 80 (HTTP). Konfigurasi HTTPS tersedia tapi dikomentari. Untuk mengaktifkan, uncomment `certificate_arn` di `variables.tf` dan tambahkan HTTPS listener di modul ALB.

---

## Quickstart

### Prerequisites

- Terraform >= 1.5.0
- Configure AWS CLI 
- Existing VPC dan Subnet 
- Prepare Github Repo
- GitHub PAT

### 1. Clone repository

```bash
git clone https://github.com/adzimatohari24/Indico-tf.git
cd Indico-tf
```

### 2. Buat file tfvars

```bash
cp examples/complete/terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` dan sesuaikan nilainya:

```hcl
aws_region   = "ap-southeast-1"
project_name = "myapp"
environment  = "dev"

# Sesuaikan dengan VPC dan Subnet yang sudah ada
vpc_id     = "vpc-0abc12345"
subnet_ids = ["subnet-0abc12345", "subnet-0def67890"]

# Container
container_name  = "myapp"
container_image = "nginx:latest"
container_port  = 80

# GitHub
repo_owner         = "your-github-username"
repo_name          = "your-repo-name"
branch             = "main"
repo_url           = "https://github.com/your-github-username/your-repo-name.git"
github_oauth_token = "ghp_xxxxxxxxxxxxxxxxxxxx"
webhook_secret     = "your-random-secret-string"
```

> **Penting:** Pastikan `terraform.tfvars` sudah masuk ke `.gitignore` karena berisi token sensitif.

### 3. Test

chmod +x /Users/fauzanadzimatohari/Documents/Kiro/Indico-tf/tf-check.sh
./tf-check.sh

### 4. Deploy

terraform init
terraform fmt
terraform validate
terraform plan
terraform apply

# Result :

### 1. Terraform init
### 2. Terraform fmt
### 3. Terraform validate
### 4. Terraform plan