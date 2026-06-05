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
│   ├── alb/                   # Application Load Balancer + Target Group + Listener
│   ├── ecs/                   # ECS Cluster, Task Definition, Service, IAM, SG
│   ├── codebuild/             # CodeBuild Project + IAM Role
│   └── codepipeline/          # CodePipeline + S3 Artifact Bucket + Webhook
└── examples/
    └── complete/              # Contoh penggunaan lengkap
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        └── terraform.tfvars.example
```

---

## Asumsi

> Baca bagian ini sebelum deploy.

1. **VPC sudah ada** — modul ini **tidak membuat VPC baru**. Kamu wajib menyediakan `vpc_id` dari VPC yang sudah ada di AWS account kamu.

2. **Subnet sudah ada** — modul ini **tidak membuat subnet**. `subnet_ids` harus diisi dengan subnet yang sudah ada. Gunakan **public subnet** agar ALB dan ECS task bisa diakses dari internet.

3. **GitHub sebagai source** — CodePipeline dikonfigurasi menggunakan GitHub (provider `ThirdParty`). Kamu perlu menyediakan GitHub OAuth token yang valid dengan akses ke repository.

4. **Container image tersedia** — image yang didefinisikan di `container_image` harus bisa di-pull oleh ECS task execution role (public Docker Hub atau ECR dengan permission yang sesuai).

5. **Buildspec tersedia di repo** — CodeBuild mengasumsikan file `buildspec.yml` sudah ada di root repository. Path bisa diubah via variabel `buildspec`.

6. **Deploy stage ke S3** — artifact hasil build disimpan ke S3 bucket. Stage Deploy di CodePipeline menggunakan S3 sebagai destination. Untuk deploy otomatis ke ECS, stage Deploy perlu diganti dengan provider `ECS`.

7. **HTTPS opsional** — ALB saat ini hanya listen di port 80 (HTTP). Konfigurasi HTTPS tersedia tapi dikomentari. Untuk mengaktifkan, uncomment `certificate_arn` di `variables.tf` dan tambahkan HTTPS listener di modul ALB.

---

## Quickstart

### Prerequisites

- Terraform >= 1.5.0
- AWS CLI sudah dikonfigurasi (`aws configure`)
- VPC dan Subnet sudah tersedia di AWS account kamu
- GitHub repository berisi source code dan file `buildspec.yml`
- GitHub Personal Access Token dengan scope `repo` dan `admin:repo_hook`

### 1. Clone repository

```bash
git clone https://github.com/<your-org>/Indico-tf.git
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

### 3. Deploy

```bash
terraform init
terraform plan
terraform apply
```

### 4. Akses aplikasi

Setelah apply selesai, ambil DNS ALB dari output:

```bash
terraform output alb_dns_name
```

Buka di browser: `http://<alb_dns_name>`

---

## Input Variables

| Variable | Deskripsi | Default |
|---|---|---|
| `aws_region` | AWS region deployment | `ap-southeast-1` |
| `project_name` | Nama project (prefix semua resource) | `demo` |
| `environment` | Environment label (dev/staging/prod) | `dev` |
| `vpc_id` | ⛔ VPC ID yang sudah ada | `vpc-xxxxxxx` |
| `subnet_ids` | ⛔ List Subnet ID yang sudah ada (public subnet) | `["subnet-xxxxxx"]` |
| `container_name` | Nama container di task definition | `nginx` |
| `container_image` | Docker image yang digunakan | `nginx:latest` |
| `container_port` | Port yang di-expose container (1-65535) | `80` |
| `desired_count` | Jumlah ECS task yang berjalan | `1` |
| `repo_url` | URL GitHub repository | — |
| `repo_owner` | GitHub username / org | — |
| `repo_name` | Nama repository GitHub | — |
| `branch` | Branch yang di-trigger pipeline | `main` |
| `buildspec` | Path ke file buildspec | `buildspec.yml` |
| `compute_type` | Tipe compute CodeBuild | `BUILD_GENERAL1_SMALL` |
| `image` | Build image CodeBuild | `amazonlinux2-x86_64-standard:5.0` |
| `env_vars` | Environment variables untuk CodeBuild | `{ ENV = "dev" }` |
| `github_oauth_token` | GitHub OAuth token (sensitive) | dummy |
| `webhook_secret` | Secret token webhook GitHub (sensitive) | dummy |

## Outputs

| Output | Deskripsi |
|---|---|
| `ecs_cluster` | Nama ECS Cluster |
| `ecs_service` | Nama ECS Service |
| `codebuild_project_name` | Nama CodeBuild project |
| `codepipeline_name` | Nama CodePipeline |
| `codepipeline_arn` | ARN CodePipeline |
| `alb_dns_name` | DNS name ALB untuk akses aplikasi |

---

## Security Notes

- `github_oauth_token` dan `webhook_secret` ditandai `sensitive = true` — tidak akan muncul di output `terraform plan` / `apply`.
- Jangan commit `terraform.tfvars` ke repository karena berisi token.
- Security group ECS saat ini membuka ingress dari `0.0.0.0/0` — cocok untuk demo, namun di production sebaiknya dibatasi hanya dari security group ALB.
- IAM policy CodeBuild dan CodePipeline sudah dibatasi ke resource yang spesifik, bukan `*`.
- Untuk production, pertimbangkan menggunakan AWS CodeStar Connections sebagai pengganti GitHub OAuth token.
