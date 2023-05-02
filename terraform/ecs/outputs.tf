output "db_endpoint" {
  value = aws_db_instance.devops.endpoint
}

output "name_servers" {
  value = aws_route53_zone.this.name_servers
}
