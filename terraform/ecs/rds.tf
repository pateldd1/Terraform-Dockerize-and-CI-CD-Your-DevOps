resource "aws_db_subnet_group" "example" {
  name       = "example"
  subnet_ids = aws_subnet.private.*.id
}

resource "aws_db_instance" "example" {
  allocated_storage         = 20
  engine                    = "postgres"
  engine_version            = "13"
  instance_class            = "db.t3.micro"
  name                      = "example_database"
  skip_final_snapshot       = false
  final_snapshot_identifier = "example-db-final-snapshot"
  username                  = jsondecode(data.aws_secretsmanager_secret_version.db_credentials.secret_string)["username"]
  password                  = jsondecode(data.aws_secretsmanager_secret_version.db_credentials.secret_string)["password"]
  vpc_security_group_ids    = [aws_security_group.db.id]
  db_subnet_group_name      = aws_db_subnet_group.example.name
}
