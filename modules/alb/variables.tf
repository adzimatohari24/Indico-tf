variable "project_name" {
  description = "Nama project, digunakan sebagai prefix semua resource"
  type        = string
}

variable "environment" {
  description = "Environment label (dev/staging/prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID tempat ALB di-deploy"
  type        = string
}

variable "subnet_ids" {
  description = "List Subnet ID untuk ALB (gunakan public subnet)"
  type        = list(string)
}

variable "container_port" {
  description = "Port container yang dijadikan target oleh ALB"
  type        = number
}

# variable "certificate_arn" {
#   description = "ARN ACM certificate untuk HTTPS listener (opsional)"
#   type        = string
#   default     = ""
# }
