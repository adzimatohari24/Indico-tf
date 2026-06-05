# Fungsi:
# Nama Load Balancer

variable "alb_name" {

  description = "Application Load Balancer Name"
  default = ""
  type = string
}

# Fungsi:
# Existing VPC ID

variable "vpc_id" {

  description = "VPC ID"

  type = string
}

# Fungsi:
# Existing Subnet IDs

variable "subnet_ids" {

  description = "Subnet IDs"

  type = list(string)
}

variable "project_name" {

  description = "Project Name"

  type = string

}
variable "environment" {}

variable "container_port" {}

variable "certificate_arn" {
  default = ""   
}

