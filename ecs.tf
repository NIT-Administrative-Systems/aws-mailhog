resource "aws_ecs_cluster" "mailhogs" {
  name = local.full_name_slug
}

resource "aws_ecs_task_definition" "mailhog" {
  family                   = local.full_name_slug
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = aws_iam_role.mailhog.arn
  task_role_arn            = aws_iam_role.mailhog.arn

  container_definitions = <<DEFINITION
[{
    "cpu": ${var.container_cpu},
    "memory": ${var.container_memory},
    "name": "${local.full_name_slug}",
    "portMappings": [
        {
          "containerPort": 8025,
          "hostPort": ${local.web_port}
        },
        {
          "containerPort": 1025,
          "hostPort": 1025
        }
    ],
    "essential": true,
    "image": "${var.container_image}",
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "${aws_cloudwatch_log_group.logs.name}",
            "awslogs-region": "${var.region}",
            "awslogs-stream-prefix": "ecs"
        }
    },
    "environment": [
        {"name": "MH_HOSTNAME", "value": "${var.hostname}"},
        {"name": "MH_STORAGE", "value": "memory"}
    ]
}]
DEFINITION
}

resource "aws_ecs_service" "ecs_task_serv" {
  name            = local.full_name_slug
  cluster         = aws_ecs_cluster.mailhogs.id
  task_definition = aws_ecs_task_definition.mailhog.arn
  desired_count   = 1

  health_check_grace_period_seconds = var.health_check_grace_period

  launch_type      = "FARGATE"
  platform_version = "LATEST"

  load_balancer {
    target_group_arn = aws_alb_target_group.webserver.arn
    container_name   = local.full_name_slug
    container_port   = local.web_port
  }

  network_configuration {
    subnets          = var.ecs_subnet_ids
    security_groups  = [aws_security_group.firewall.id]
    assign_public_ip = false
  }

  depends_on = [
    aws_iam_role.mailhog,
    aws_cloudwatch_log_group.logs,
  ]
}