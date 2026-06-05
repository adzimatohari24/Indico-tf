# Naming
locals {
  name = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# S3 BUCKET (artifact storage)
resource "aws_s3_bucket" "artifact" {
  bucket        = "${local.name}-artifact-bucket"
  force_destroy = true

  tags = local.common_tags
}

resource "aws_s3_bucket_versioning" "artifact" {
  bucket = aws_s3_bucket.artifact.id

  versioning_configuration {
    status = "Enabled"
  }
}

# IAM ROLE FOR CODEPIPELINE
resource "aws_iam_role" "codepipeline" {
  name = "${local.name}-codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "codepipeline.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = local.common_tags
}

# Policy untuk akses pipeline - scope dibatasi ke resource yang relevan
resource "aws_iam_role_policy" "codepipeline" {
  role = aws_iam_role.codepipeline.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:GetBucketVersioning"
        ]
        Resource = [
          "arn:aws:s3:::${local.name}-artifact-bucket",
          "arn:aws:s3:::${local.name}-artifact-bucket/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds"
        ]
        Resource = "arn:aws:codebuild:*:*:project/${var.codebuild_project_name}"
      }
    ]
  })
}

# CODEPIPELINE RESOURCE
resource "aws_codepipeline" "this" {
  name     = "${local.name}-pipeline"
  role_arn = aws_iam_role.codepipeline.arn

  # tempat artifact antar stage
  artifact_store {
    location = aws_s3_bucket.artifact.bucket
    type     = "S3"
  }

  # STAGE 1: SOURCE (GitHub)
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner      = var.repo_owner
        Repo       = var.repo_name
        Branch     = var.branch
        OAuthToken = var.github_oauth_token
      }
    }
  }

  # STAGE 2: BUILD (CodeBuild)
  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"

      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = var.codebuild_project_name
      }
    }
  }

  # STAGE 3: DEPLOY (artifact ke S3)
  stage {
    name = "Deploy"

    action {
      name     = "Deploy"
      category = "Deploy"
      owner    = "AWS"
      provider = "S3"
      version  = "1"

      input_artifacts = ["build_output"]

      configuration = {
        BucketName = aws_s3_bucket.artifact.bucket
        Extract    = "true"
      }
    }
  }

  tags = local.common_tags
}

# WEBHOOK
resource "aws_codepipeline_webhook" "this" {
  name            = "${local.name}-webhook"
  authentication  = "GITHUB_HMAC"
  target_action   = "Source"
  target_pipeline = aws_codepipeline.this.name

  authentication_configuration {
    secret_token = var.webhook_secret
  }

  filter {
    json_path    = "$.ref"
    match_equals = "refs/heads/${var.branch}"
  }
}
