# GLOBAL
variable "aws_region" {
  description = "AWS region deployment"
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Nama project, digunakan sebagai prefix semua resource"
  type        = string
  default     = "demo"
}

variable "environment" {
  description = "Environment label (dev/staging/prod)"
  type        = string
  default     = "dev"
}

# NETWORK
variable "vpc_id" {
  description = "VPC ID yang sudah ada di AWS account kamu"
  type        = string
}

variable "subnet_ids" {
  description = "List Subnet ID yang sudah ada (gunakan public subnet)"
  type        = list(string)
}

# CONTAINER
variable "container_name" {
  description = "Nama container di dalam task definition"
  type        = string
  default     = "nginx"
}

variable "container_image" {
  description = "Docker image yang digunakan container"
  type        = string
  default     = "nginx:latest"
}

variable "container_port" {
  description = "Port yang di-expose oleh container"
  type        = number
  default     = 80
}

# ECS
variable "desired_count" {
  description = "Jumlah ECS task yang ingin dijalankan"
  type        = number
  default     = 1
}

# CODEBUILD
variable "repo_url" {
  description = "URL GitHub repository source code"
  type        = string
}

variable "buildspec" {
  description = "Path ke file buildspec di dalam repository"
  type        = string
  default     = "buildspec.yml"
}

variable "compute_type" {
  description = "Tipe compute CodeBuild"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "image" {
  description = "Build image yang digunakan CodeBuild"
  type        = string
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
}

variable "env_vars" {
  description = "Map environment variables yang di-inject ke CodeBuild"
  type        = map(string)
  default     = { ENV = "dev" }
}

# CODEPIPELINE
variable "repo_owner" {
  description = "GitHub username atau organisasi pemilik repository"
  type        = string
}

variable "repo_name" {
  description = "Nama repository GitHub"
  type        = string
}

variable "branch" {
  description = "Branch yang memicu pipeline"
  type        = string
  default     = "main"
}

variable "github_oauth_token" {
  description = "GitHub OAuth token untuk akses repository"
  type        = string
  sensitive   = true
  default     = "dummy-token-replace-before-use"
}

variable "webhook_secret" {
  description = "Secret token untuk validasi webhook dari GitHub"
  type        = string
  sensitive   = true
  default     = "dummy-webhook-secret-replace-before-use"
}
