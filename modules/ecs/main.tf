# naming prefix biar rapi
locals {
  name = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ECS CLUSTER
resource "aws_ecs_cluster" "this" {
  name = "${local.name}-cluster"

  tags = local.common_tags
}

# LOG GROUP
resource "aws_cloudwatch_log_group" "this" {
  name = "/ecs/${local.name}"

  tags = local.common_tags
}

# IAM EXECUTION ROLE
resource "aws_iam_role" "exec" {
  name = "${local.name}-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = local.common_tags
}

# policy wajib ECS
resource "aws_iam_role_policy_attachment" "exec_attach" {
  role       = aws_iam_role.exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# SECURITY GROUP
resource "aws_security_group" "this" {
  name   = "${local.name}-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # open (demo)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

# TASK DEFINITION
resource "aws_ecs_task_definition" "this" {
  family                   = "${local.name}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = "256"
  memory = "512"

  execution_role_arn = aws_iam_role.exec.arn

  container_definitions = jsonencode([{
    name  = var.container_name
    image = var.container_image

    essential = true

    portMappings = [{
      containerPort = var.container_port
      hostPort      = var.container_port
    }]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.this.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])

  tags = local.common_tags
}

# ECS SERVICE
resource "aws_ecs_service" "this" {
  name            = "${local.name}-svc"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn

  launch_type   = "FARGATE"
  desired_count = var.desired_count

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.this.id]
    assign_public_ip = true
  }

  # ALB INTEGRATION
  dynamic "load_balancer" {
    for_each = var.target_group_arn != "" ? [1] : []

    content {
      target_group_arn = var.target_group_arn
      container_name   = var.container_name
      container_port   = var.container_port
    }
  }

  # Abaikan perubahan task_definition agar deployment via CodePipeline
  # tidak di-override saat terraform apply dijalankan ulang
  lifecycle {
    ignore_changes = [task_definition]
  }

  tags = local.common_tags
}
