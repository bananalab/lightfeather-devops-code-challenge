resource "aws_ecs_cluster" "this" {
  name = "app"
}

resource "aws_ecs_task_definition" "app" {
  family                   = "app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode(
    [
      {
        name      = "backend"
        image     = "${aws_ecr_repository.this["backend"].repository_url}:main"
        essential = true
        environment = [{
          name  = "CORS_ORIGIN"
          value = "http://${aws_lb.this.dns_name}:3000/"
        }]
        portMappings = [{
          protocol      = "tcp"
          containerPort = 8080
          hostPort      = 8080
        }]
      },
      {
        name      = "frontend"
        image     = "${aws_ecr_repository.this["frontend"].repository_url}:main"
        essential = true
        environment = [{
          name  = "API_URL"
          value = "http://${aws_lb.this.dns_name}:8080/"
        }]
        portMappings = [{
          protocol      = "tcp"
          containerPort = 3000
          hostPort      = 3000
        }]
      }
    ]
  )
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "test-ecsTaskExecutionRole"

  assume_role_policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
                {
                    "Action": "sts:AssumeRole",
                    "Principal": {
                    "Service": "ecs-tasks.amazonaws.com"
                    },
                    "Effect": "Allow",
                    "Sid": ""
                }
            ]
    }
    EOF
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_service" "this" {
  name                               = "app"
  cluster                            = aws_ecs_cluster.this.id
  task_definition                    = aws_ecs_task_definition.app.arn
  desired_count                      = 2
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"

  network_configuration {
    subnets          = [for subnet in module.vpc.result.private_subnets : subnet.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.frontend.arn
    container_name   = "frontend"
    container_port   = 3000
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.backend.arn
    container_name   = "backend"
    container_port   = 8080
  }
}
