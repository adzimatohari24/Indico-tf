variable "project_name" {
  description = "Nama project, digunakan sebagai prefix semua resource"
  type        = string
}

variable "environment" {
  description = "Environment label (dev/staging/prod)"
  type        = string
}

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

variable "codebuild_project_name" {
  description = "Nama CodeBuild project yang digunakan di stage Build"
  type        = string
}

variable "github_oauth_token" {
  description = "GitHub OAuth token untuk akses repository. Ganti dengan token asli sebelum deploy ke production"
  type        = string
  sensitive   = true
  default     = "dummy-token-replace-before-use"
}

variable "webhook_secret" {
  description = "Secret token untuk validasi webhook dari GitHub. Ganti dengan nilai acak yang kuat sebelum deploy ke production"
  type        = string
  sensitive   = true
  default     = "dummy-webhook-secret-replace-before-use"
}
