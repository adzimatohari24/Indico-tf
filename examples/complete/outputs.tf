output "alb_dns_name" {
  description = "DNS name ALB untuk akses aplikasi"
  value       = module.alb.alb_dns_name
}

output "ecs_cluster" {
  description = "Nama ECS Cluster yang dibuat"
  value       = module.ecs.cluster_name
}

output "ecs_service" {
  description = "Nama ECS Service yang dibuat"
  value       = module.ecs.service_name
}

output "codebuild_project_name" {
  description = "Nama CodeBuild project yang dibuat"
  value       = module.codebuild.project_name
}

output "codepipeline_name" {
  description = "Nama CodePipeline yang dibuat"
  value       = module.codepipeline.pipeline_name
}

output "codepipeline_arn" {
  description = "ARN CodePipeline yang dibuat"
  value       = module.codepipeline.pipeline_arn
}
