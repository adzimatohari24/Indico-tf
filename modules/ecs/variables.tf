variable "project_name" {
  description = "Nama project, digunakan sebagai prefix semua resource"
  type        = string
}

variable "environment" {
  description = "Environment label (dev/staging/prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID tempat ECS service di-deploy"
  type        = string
}

variable "subnet_ids" {
  description = "List Subnet ID untuk ECS service dan ALB"
  type        = list(string)
}

variable "container_name" {
  description = "Nama container di dalam task definition"
  type        = string
}

variable "container_image" {
  description = "Docker image yang digunakan container (e.g. nginx:latest)"
  type        = string
}

variable "container_port" {
  description = "Port yang di-expose oleh container (1-65535)"
  type        = number

  validation {
    condition     = var.container_port > 0 && var.container_port <= 65535
    error_message = "container_port harus bernilai antara 1 dan 65535."
  }
}

variable "desired_count" {
  description = "Jumlah ECS task yang ingin dijalankan"
  type        = number
  default     = 1
}

variable "aws_region" {
  description = "AWS region tempat resource di-deploy, digunakan untuk awslogs-region"
  type        = string
  default     = "ap-southeast-1"
}

variable "target_group_arn" {
  description = "ARN Target Group ALB. Kosongkan jika tidak menggunakan ALB"
  type        = string
  default     = ""
}
