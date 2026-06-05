output "alb_dns_name" {
  description = "DNS name ALB untuk akses aplikasi"
  value       = aws_lb.this.dns_name
}

output "target_group_arn" {
  description = "ARN Target Group yang digunakan ECS service"
  value       = aws_lb_target_group.this.arn
}
