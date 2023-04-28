variable "aws_region" {
  description = "AWS region for the infrastructure"
  type        = string
}
variable "environment" {
  description = "Environment for the infrastructure (e.g., dev, prod)"
  type        = string
}
variable "db_instance_type" {
  description = "Instance type for EC2 instances and ECS tasks"
  type        = string
}

variable "db_engine_version" {
  description = "Engine version for database"
  type        = string
}
variable "db_allocated_storage_in_gb" {
  description = 20
  type        = number
}
variable "ecr_image" {
  description = "ECR Image name:tag"
  type        = string
}
variable "ecs_task_cpu" {
  description = "ECS task cpu"
  type        = string
}
variable "ecs_task_memory" {
  description = "ECS Task memory"
  type        = string
}
variable "bastion_instance_type" {
  description = "Bastion Host EC2 instance type"
  type        = string
}
variable "bastion_key_name" {
  description = "Key name for bastion host access in ~/.ssh folder"
  type        = string
}
variable "bastion_instance_ami" {
  description = "EC2 ami for the Bastion"
  type        = string
}
variable "alb_target_group_healthcheck_path" {
  description = "ALB target group health check pattern"
  type        = string
}
