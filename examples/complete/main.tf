# Terraform + Provider
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ECS MODULE (existing)
module "ecs" {
  source = "./modules/ecs"

  project_name = var.project_name
  environment  = var.environment

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  container_name  = var.container_name
  container_image = var.container_image
  container_port  = var.container_port

  desired_count = var.desired_count

  target_group_arn = module.alb.target_group_arn

}

# CODEBUILD MODULE
module "codebuild" {
  source = "./modules/codebuild"

  project_name = var.project_name
  environment  = var.environment

  repo_url  = var.repo_url
  buildspec = var.buildspec

  compute_type = var.compute_type
  image        = var.image

  env_vars = var.env_vars
}

# CODEPIPELINE MODULE
module "codepipeline" {
  source = "./modules/codepipeline"

  project_name = var.project_name
  environment  = var.environment

  repo_owner = var.repo_owner
  repo_name  = var.repo_name
  branch     = var.branch

  codebuild_project_name = module.codebuild.project_name
}

# ALB MODULE
module "alb" {
  source = "./modules/alb"

  project_name = var.project_name
  environment  = var.environment

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  container_port = var.container_port

  # OPTIONAL SSL
  #  certificate_arn = var.certificate_arn
}
