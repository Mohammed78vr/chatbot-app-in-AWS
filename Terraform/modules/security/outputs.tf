# Security Module Outputs

output "web_security_group_id" {
  description = "ID of the web security group"
  value       = aws_security_group.web.id
}