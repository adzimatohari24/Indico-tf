# GLOBAL SETTING
variable "aws_region" {
  default = "ap-southeast-1"
}

variable "project_name" {
  default = "demo"
}

variable "environment" {
  default = "dev"
}

# NETWORK (WAJIB kamu isi sesuai AWS kamu)
variable "vpc_id" {
  default = "vpc-xxxxxxx" # ⛔ GANTI INI
}

variable "subnet_ids" {
  default = ["subnet-xxxxxx"] # ⛔ GANTI INI
}

# CONTAINER
variable "container_name" {
  default = "nginx"
}

variable "container_image" {
  default = "nginx:latest"
}

variable "container_port" {
  default = 80
}

# ECS SERVICE
variable "desired_count" {
  default = 1
}

# CodeBuild
variable "repo_url" {
  description = "Repository URL (GitHub/GitLab)"
  default     = "https://github.com/example/repo.git"
}

variable "buildspec" {
  description = "Path buildspec file"
  default     = "buildspec.yml"
}

variable "compute_type" {
  default = "BUILD_GENERAL1_SMALL"
}

variable "image" {
  default = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
}

variable "env_vars" {
  type = map(string)

  default = {
    ENV = "dev"
  }
}

variable "repo_owner" {
  default = "github-username"
}

variable "repo_name" {
  default = "repo-name"
}

variable "branch" {
  default = "main"
}

#variable "certificate_arn" {
#  description = "ACM certificate ARN (optional)"
#  default     = ""   # kosong jika tidak pakai HTTPS
#}
