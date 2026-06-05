variable "project_name" {
  description = "Nama project, digunakan sebagai prefix semua resource"
  type        = string
}

variable "environment" {
  description = "Environment label (dev/staging/prod)"
  type        = string
}

variable "repo_url" {
  description = "URL GitHub repository source code"
  type        = string
  default     = "https://github.com/username/repo.git"
}

variable "buildspec" {
  description = "Path ke file buildspec di dalam repository"
  type        = string
  default     = "buildspec.yml"
}

variable "compute_type" {
  description = "Tipe compute CodeBuild (BUILD_GENERAL1_SMALL / MEDIUM / LARGE)"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"

  validation {
    condition     = contains(["BUILD_GENERAL1_SMALL", "BUILD_GENERAL1_MEDIUM", "BUILD_GENERAL1_LARGE"], var.compute_type)
    error_message = "compute_type harus salah satu dari: BUILD_GENERAL1_SMALL, BUILD_GENERAL1_MEDIUM, BUILD_GENERAL1_LARGE."
  }
}

variable "image" {
  description = "Build image yang digunakan CodeBuild"
  type        = string
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
}

variable "env_vars" {
  description = "Map environment variables yang di-inject ke CodeBuild build"
  type        = map(string)
  default     = { ENV = "dev" }
}

variable "privileged_mode" {
  description = "Set true jika build perlu menjalankan Docker (Docker-in-Docker)"
  type        = bool
  default     = false
}
