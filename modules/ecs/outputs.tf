output "cluster_name" {
  description = "Nama ECS Cluster yang dibuat"
  value       = aws_ecs_cluster.this.name
}

output "service_name" {
  description = "Nama ECS Service yang dibuat"
  value       = aws_ecs_service.this.name
}
