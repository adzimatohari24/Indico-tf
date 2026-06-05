variable "project_name" {}
variable "environment" {}

variable "repo_owner" {}
variable "repo_name" {}
variable "branch" {}

variable "codebuild_project_name" {}

variable "webhook_secret" {
  default = "my-secret-token"
}
