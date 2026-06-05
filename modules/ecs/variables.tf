variable "project_name" {}
variable "environment" {}

variable "vpc_id" {}
variable "subnet_ids" {}

variable "container_name" {}
variable "container_image" {}
variable "container_port" {}

variable "desired_count" {
  default = 1
}

variable "aws_region" {
  default = "ap-southeast-1"
}

variable "target_group_arn" {
  default = ""
}
