# 4. Outputs
#   4.1 Endpoint
#   4.2 Port

output "endpoint" {
  value = aws_db_instance.mysql.endpoint
}

output "port" {
  value = aws_db_instance.mysql.port
}
