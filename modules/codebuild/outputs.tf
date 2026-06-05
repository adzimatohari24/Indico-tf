output "project_name" {
  description = "Nama CodeBuild project yang dibuat"
  value       = aws_codebuild_project.this.name
}

output "project_arn" {
  description = "ARN CodeBuild project yang dibuat"
  value       = aws_codebuild_project.this.arn
}
