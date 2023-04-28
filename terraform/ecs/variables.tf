variable "domain_name" {
  description = "Domain name for the application"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "subnet_cidr_blocks" {
  description = "CIDR blocks for the subnets"
  type        = list(string)
}

variable "environment" {
  description = "Environment for the infrastructure (e.g., dev, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region for the infrastructure"
  type        = string
}

variable "route53_zone_id" {
  description = "Route 53 zone ID"
  type        = string
}

variable "ecs_task_definition" {
  description = "ECS task definition parameters"
  type        = map(any)
}

variable "instance_type" {
  description = "Instance type for EC2 instances and ECS tasks"
  type        = string
}

variable "autoscaling_config" {
  description = "Autoscaling configuration (min/max/desired capacity)"
  type        = map(number)
}

variable "load_balancer_settings" {
  description = "Load balancer settings (e.g., health check configuration)"
  type        = map(any)
}

variable "database_settings" {
  description = "Database settings (e.g., instance class, storage size, etc.)"
  type        = map(any)
}
