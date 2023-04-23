resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "devops-vpc"
  }
}

resource "aws_subnet" "private" {
  count = 3

  cidr_block        = "10.0.${count.index + 1}.0/24"
  vpc_id            = aws_vpc.this.id
  availability_zone = "us-east-1${element(["a", "b", "c"], count.index)}"

  tags = {
    Name = "devops-private-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "public" {
  count = 3

  cidr_block        = "10.0.${count.index + 101}.0/24"
  vpc_id            = aws_vpc.this.id
  availability_zone = "us-east-1${element(["a", "b", "c"], count.index)}"

  tags = {
    Name = "devops-public-subnet-${count.index + 1}"
  }
}

resource "aws_security_group" "db" {
  name        = "devops-db"
  description = "Allow traffic to PostgreSQL"
  vpc_id      = aws_vpc.this.id
}

resource "aws_security_group" "ecs" {
  name        = "devops-ecs"
  description = "Allow traffic to ECS services"
  vpc_id      = aws_vpc.this.id
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "main" {
  name        = "main-sg"
  description = "Main security group"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
