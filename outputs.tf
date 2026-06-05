#ECS Cluster
output "ecs_cluster" {
  value = module.ecs.cluster_name
}

output "ecs_service" {
  value = module.ecs.service_name
}

#CodeBuild
output "codebuild_project_name" {
  value = module.codebuild.project_name
}

#CODEPIPELINE
output "codepipeline_name" {
  value = module.codepipeline.pipeline_name # ambil dari module
}

output "codepipeline_arn" {
  value = module.codepipeline.pipeline_arn
}

#ALB
output "alb_dns_name" {
  value = module.alb.alb_dns_name
}
