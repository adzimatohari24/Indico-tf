# Naming
locals {
  name = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# IAM ROLE FOR CODEBUILD
resource "aws_iam_role" "codebuild" {
  name = "${local.name}-codebuild-role"

  # Allow CodeBuild service to assume role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "codebuild.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = local.common_tags
}

# IAM POLICY - scope dibatasi ke resource yang relevan
resource "aws_iam_role_policy" "codebuild" {
  role = aws_iam_role.codebuild.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:log-group:/codebuild/${local.name}:*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::${var.project_name}-${var.environment}-artifact-bucket/*"
      }
    ]
  })
}

# CLOUDWATCH LOG GROUP
resource "aws_cloudwatch_log_group" "codebuild" {
  name = "/codebuild/${local.name}"

  tags = local.common_tags
}

# CODEBUILD PROJECT
resource "aws_codebuild_project" "this" {
  name         = "${local.name}-cb"
  description  = "CodeBuild project for ${local.name}"
  service_role = aws_iam_role.codebuild.arn

  build_timeout = 30

  # ARTIFACT (no output file)
  artifacts {
    type = "NO_ARTIFACTS"
  }

  # BUILD ENVIRONMENT
  environment {
    compute_type    = var.compute_type
    image           = var.image
    type            = "LINUX_CONTAINER"
    privileged_mode = var.privileged_mode

    # Inject environment variables
    dynamic "environment_variable" {
      for_each = var.env_vars
      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }
  }

  # SOURCE (GitHub)
  source {
    type      = "GITHUB"
    location  = var.repo_url
    buildspec = var.buildspec
  }

  # LOGS
  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.codebuild.name
    }
  }

  tags = local.common_tags
}
