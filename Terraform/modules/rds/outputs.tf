output "db_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = aws_db_instance.chatbot_db.endpoint
}

output "db_port" {
  description = "Port of the RDS instance"
  value       = aws_db_instance.chatbot_db.port
}

output "db_name" {
  description = "Name of the database"
  value       = aws_db_instance.chatbot_db.db_name
}

output "db_username" {
  description = "Username for the database"
  value       = aws_db_instance.chatbot_db.username
}

output "rds_security_group_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds_sg.id
}
