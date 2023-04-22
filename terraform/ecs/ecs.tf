resource "aws_ecs_cluster" "this" {
  name = "example-cluster"
}

resource "aws_ecs_task_definition" "this" {
  family                   = "example-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
    name  = "example-app"
    image = "example-image"
    portMappings = [{
      containerPort = 80
    }]

    secrets = [
      {
        name      = "DB_USER"
        valueFrom = "${data.aws_secretsmanager_secret_version.db_credentials.arn}:username::"
      },
      {
        name      = "DB_PASS"
        valueFrom = "${data.aws_secretsmanager_secret_version.db_credentials.arn}:password::"
      },
      {
        name      = "DB_HOST"
        valueFrom = "${data.aws_secretsmanager_secret_version.db_credentials.arn}:DB_HOST::"
      },
      {
        name      = "DB_NAME"
        valueFrom = "${data.aws_secretsmanager_secret_version.db_credentials.arn}:DB_NAME::"
      }
    ]
  }])
}

resource "aws_ecs_service" "this" {
  name            = "example-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets = aws_subnet.private.*.id
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = "example-app"
    container_port   = 80
  }

  desired_count = 1

  depends_on = [aws_db_instance.example, aws_lb_listener.this]
}
