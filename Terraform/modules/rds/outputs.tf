output "db_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.chatbot_db.endpoint
}

output "db_port" {
  description = "RDS instance port"
  value       = aws_db_instance.chatbot_db.port
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.chatbot_db.db_name
}

output "security_group_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds_sg.id
}
