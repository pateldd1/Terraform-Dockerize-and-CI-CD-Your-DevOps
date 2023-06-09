aws_region                        = "us-east-1"
environment                       = "prod"
db_instance_type                  = "db.t3.micro"
db_engine_version                 = "13"
db_allocated_storage_in_gb        = 20
ecr_image                         = "429363805278.dkr.ecr.us-east-1.amazonaws.com/astrapredict:latest"
ecs_task_cpu                      = "256"
ecs_task_memory                   = "512"
bastion_instance_type             = "t2.micro"
bastion_key_name                  = "devpatel-keys"
bastion_instance_ami              = "ami-0533f2ba8a1995cf9"
alb_target_group_healthcheck_path = "/"
fqdn                              = "terraform.thecryptome.com"
domain_name                       = "thecryptome.com"
