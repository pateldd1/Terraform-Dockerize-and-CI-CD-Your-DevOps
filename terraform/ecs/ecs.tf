resource "aws_ecs_cluster" "this" {
  name = "devops-cluster"
}

resource "aws_ecs_task_definition" "this" {
  family                   = "devops-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
    name  = "devops-app"
    image = "429363805278.dkr.ecr.us-east-1.amazonaws.com/interview:latest"
    portMappings = [{
      containerPort = 80
    }]

    environment = [
      {
        name  = "DB_HOST"
        value = aws_db_instance.devops.endpoint
      }
    ]

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
        name      = "DB_NAME"
        valueFrom = "${data.aws_secretsmanager_secret_version.db_credentials.arn}:DB_NAME::"
      },
      {
        name      = "PORT"
        valueFrom = "${data.aws_secretsmanager_secret_version.db_credentials.arn}:PORT::"
      }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/devops-task"
        awslogs-region        = "us-east-1"
        awslogs-stream-prefix = "ecs"
      }
    }
  }])
}

resource "aws_ecs_service" "this" {
  name            = "devops-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.private.*.id
    security_groups  = [aws_security_group.main.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = "devops-app"
    container_port   = 80
  }

  desired_count = 1

  depends_on = [aws_db_instance.devops, aws_lb_listener.this]
}
