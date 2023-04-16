provider "aws" {
  region = "us-west-2"
}

locals {
  cluster_name = "my-ecs-cluster"
  azs          = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

data "aws_default_security_group" "default" {
  vpc_id = aws_vpc.this.id
}

resource "aws_vpc" "this" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "ECS-VPC"
  }
}

resource "aws_subnet" "public" {
  count = length(local.azs)

  cidr_block        = "10.0.${count.index + 1}.0/24"
  vpc_id            = aws_vpc.this.id
  availability_zone = local.azs[count.index]

  tags = {
    Name = "ECS-Public-Subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count = length(local.azs)

  cidr_block        = "10.0.${count.index + 101}.0/24"
  vpc_id            = aws_vpc.this.id
  availability_zone = local.azs[count.index]

  tags = {
    Name = "ECS-Private-Subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "ECS-Internet-Gateway"
  }
}

resource "aws_eip" "nat" {
  count = 2
  vpc   = true

  tags = {
    Name = "ECS-NAT-EIP-${count.index + 1}"
  }
}

resource "aws_nat_gateway" "this" {
  count = 2

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "ECS-NAT-Gateway-${count.index + 1}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "ECS-Public-Route-Table"
  }
}

resource "aws_route_table" "private" {
  count = 2

  vpc_id = aws_vpc.this.id

  tags = {
    Name = "ECS-Private-Route-Table-${count.index + 1}"
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route" "private" {
  count = 2

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[count.index].id
}

resource "aws_route_table_association" "public" {
  count = 2

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = 2

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_security_group" "bastion" {
  name        = "ECS-Bastion-SG"
  description = "Security group for the bastion host"
  vpc_id      = aws_vpc.this.id
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "bastion_egress" {
  security_group_id = data.aws_default_security_group.default.id

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_instance" "bastion" {
  ami           = "ami-0c55b159cbfafe1f0" # This is an example Amazon Linux 2 AMI ID; replace with the appropriate AMI ID for your region
  instance_type = "t2.micro"

  subnet_id = aws_subnet.public[0].id
  key_name  = "your-key-pair-name" # Replace with your key pair name

  vpc_security_group_ids = [data.aws_default_security_group.default.id]

  tags = {
    Name = "ECS-Bastion-Host"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y python3-pip
              pip3 install ansible
              aws s3 cp s3://your-bucket-name/crowdstrike_install.yml /tmp/crowdstrike_install.yml
              ansible-playbook /tmp/crowdstrike_install.yml
              EOF
}

resource "aws_security_group" "ecs_tasks" {
  name        = "ECS-Tasks-SG"
  description = "Security group for ECS tasks"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name = "ECS-Tasks-SG"
  }
}

resource "aws_ecs_cluster" "this" {
  name = local.cluster_name
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_execution_role.name
}

resource "aws_iam_role" "ecs_task_role" {
  name = "ecs_task_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}
# Allow the ECS task to talk to RDS.
resource "aws_iam_role_policy_attachment" "ecs_task_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
  role       = aws_iam_role.ecs_task_role.name
}

resource "aws_iam_role_policy" "ecs_task_role_policy" {
  name = "ecs_task_role_policy"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

variable "my_secret_value" {
  default = ""
}

resource "aws_secretsmanager_secret" "my_secret" {
  name        = "my_secret"
  description = "This is a secret for demonstration purposes"
}

# pass in the secret at runtime when doing terraform apply
resource "aws_secretsmanager_secret_version" "my_secret_version" {
  secret_id     = aws_secretsmanager_secret.my_secret.id
  secret_string = lookup(var.my_secret_value, "")
}

resource "aws_ecs_task_definition" "this" {
  family                   = "my-ecs-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "interview-container"
      image = "429363805278.dkr.ecr.us-east-1.amazonaws.com/interview:latest"
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ],
      essential = true
    }
  ])
}

resource "aws_ecs_service" "this" {
  name            = "my-ecs-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.private.*.id
    security_groups  = [data.aws_default_security_group.default.id]
    assign_public_ip = false
  }

  tags = {
    Name = "ECS-Service"
  }

  depends_on = [aws_lb_listener.frontend]
}

resource "aws_lb" "this" {
  name               = "ECS-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public.*.id

  tags = {
    Name = "ECS-ALB"
  }
}

resource "aws_security_group" "alb" {
  name        = "ECS-ALB-SG"
  description = "Security group for the Application Load Balancer"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name = "ECS-ALB-SG"
  }
}

resource "aws_security_group_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id

  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_https" {
  security_group_id = aws_security_group.alb.id

  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_lb_target_group" "this" {
  name     = "ECS-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.this.id

  health_check {
    healthy_threshold   = "3"
    unhealthy_threshold = "3"
    timeout             = "5"
    interval            = "30"
    path                = "/health"
  }
}

resource "aws_lb_listener" "frontend" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_db_instance" "this" {
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "13.4"
  instance_class         = "db.t2.micro"
  name                   = "terraform_practice_db"
  username               = local.secrets.db_username
  password               = local.secrets.db_password
  parameter_group_name   = "default.postgres13"
  skip_final_snapshot    = true
  publicly_accessible    = false
  vpc_security_group_ids = [data.aws_default_security_group.default.id]
}
