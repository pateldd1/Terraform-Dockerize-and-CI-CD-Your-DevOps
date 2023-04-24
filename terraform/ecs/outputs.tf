output "db_endpoint" {
  value = aws_db_instance.devops.endpoint
}

output "ssm" {
  value = "${aws_ssm_parameter.db_host.arn}:DB_HOST::"
}

output "db" {
  value = data.aws_secretsmanager_secret_version.db_credentials.arn
}


