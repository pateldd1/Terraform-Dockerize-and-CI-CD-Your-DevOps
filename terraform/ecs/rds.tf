resource "aws_db_subnet_group" "devops" {
  name       = "db_subnet_group"
  subnet_ids = aws_subnet.private.*.id
}

resource "aws_db_instance" "devops" {
  allocated_storage         = var.db_allocated_storage_in_gb
  engine                    = "postgres"
  engine_version            = var.db_engine_version
  instance_class            = var.db_instance_type
  db_name                   = "devopsDB"
  skip_final_snapshot       = true
  final_snapshot_identifier = "snapshot-db"
  username                  = jsondecode(data.aws_secretsmanager_secret_version.db_credentials.secret_string)["username"]
  password                  = jsondecode(data.aws_secretsmanager_secret_version.db_credentials.secret_string)["password"]
  vpc_security_group_ids    = [aws_security_group.main.id]
  db_subnet_group_name      = aws_db_subnet_group.devops.name
}
