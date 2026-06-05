# Naming
locals {
  name = "${var.project_name}-${var.environment}"
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
}

# Attach policy (logs + S3 basic)
resource "aws_iam_role_policy" "codebuild" {
  role = aws_iam_role.codebuild.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = "*"
      }
    ]
  })
}

# CLOUDWATCH LOG GROUP
resource "aws_cloudwatch_log_group" "codebuild" {
  name = "/codebuild/${local.name}"
}

# CODEBUILD PROJECT
resource "aws_codebuild_project" "this" {
  name         = "${local.name}-cb"
  description  = "CodeBuild project"
  service_role = aws_iam_role.codebuild.arn

  build_timeout = 30

  # ARTIFACT (no output file)
  artifacts {
    type = "NO_ARTIFACTS"
  }

  # BUILD ENVIRONMENT
  environment {
    compute_type = var.compute_type
    image        = var.image
    type         = "LINUX_CONTAINER"

    # Inject environment variables
    dynamic "environment_variable" {
      for_each = var.env_vars
      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }
  }

  # SOURCE (GitHub / GitLab)
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
}
