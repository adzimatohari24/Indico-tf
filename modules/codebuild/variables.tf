variable "project_name" {}
variable "environment" {}

variable "repo_url" {
  default = "https://github.com/username/repo.git"
}

variable "buildspec" {
  default = "buildspec.yml"
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

