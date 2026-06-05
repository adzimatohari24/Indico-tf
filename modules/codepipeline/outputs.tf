output "pipeline_name" {
  description = "Nama CodePipeline yang dibuat"
  value       = aws_codepipeline.this.name
}

output "pipeline_arn" {
  description = "ARN CodePipeline yang dibuat"
  value       = aws_codepipeline.this.arn
}
