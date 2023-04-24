resource "aws_db_subnet_group" "devops" {
  name       = "devops"
  subnet_ids = aws_subnet.private.*.id
}

resource "aws_db_instance" "devops" {
  allocated_storage         = 20
  engine                    = "postgres"
  engine_version            = "13"
  instance_class            = "db.t3.micro"
  db_name                   = "devops_database"
  skip_final_snapshot       = false
  final_snapshot_identifier = "devops-db-final-snapshot"
  username                  = jsondecode(data.aws_secretsmanager_secret_version.db_credentials.secret_string)["username"]
  password                  = jsondecode(data.aws_secretsmanager_secret_version.db_credentials.secret_string)["password"]
  vpc_security_group_ids    = [aws_security_group.main.id]
  db_subnet_group_name      = aws_db_subnet_group.devops.name
}
