resource "aws_ecs_cluster" "my_cluster" {
  name = "my-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name = "/ecs/my-logs"
}


resource "aws_ecs_task_definition" "my_task" {
  family                   = "my_task_family"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_exec_role.arn

  container_definitions = jsonencode([
    {
      name      = "my_container"
      image     = "${aws_ecr_repository.my_repository.repository_url}:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "my_service" {
  name            = "my-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my_task.arn
  desired_count   = 3
  launch_type     = "FARGATE"

#   capacity_provider_strategy {
#     capacity_provider = "FARGATE"
#     weight            = 1
#   }

  network_configuration {
    subnets = aws_subnet.my_subnet[*].id
    security_groups = [aws_security_group.alb_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.my_tg.arn
    container_name   = "my_container"
    container_port   = 80
  }

  force_new_deployment = true

  depends_on = [
    aws_lb_listener.my_listener
  ]

#   launch_type = "FARGATE"
}