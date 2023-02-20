
resource "aws_ecs_cluster" "keinomur" {
  name = "keinomur"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_service" "keinomur" {
  name                   = "keinomur"
  cluster                = aws_ecs_cluster.keinomur.arn
  task_definition        = aws_ecs_task_definition.stub.arn
  desired_count          = 1
  launch_type            = "FARGATE"
  platform_version       = "1.4.0"
  enable_execute_command = true

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [aws_security_group.keinomur.id]
  }
}

resource "aws_ecs_task_definition" "stub" {
  family                   = "keinomur"
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.keinomur.arn
  execution_role_arn       = aws_iam_role.keinomur.arn
  container_definitions = jsonencode([
    {
      name      = "keinomur",
      image     = "public.ecr.aws/amazonlinux/amazonlinux:2",
      essential = true,
      cpu       = 256,
      memory    = 512,
      portMappings = [
        {
          containerPort = 8080,
          hostPort      = 8080,
          protocol      = "tcp"
        }
      ],
      command = [
        "tail",
        "-f",
        "/dev/null"
      ],
      linuxParameters = {
        initProcessEnabled = true
      }
    }
  ])
}
