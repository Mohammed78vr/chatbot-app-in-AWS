output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "frontend_private_subnet_ids" {
  description = "List of frontend private subnet IDs"
  value       = aws_subnet.frontend_private[*].id
}

output "backend_private_subnet_ids" {
  description = "List of backend private subnet IDs"
  value       = aws_subnet.backend_private[*].id
}

output "chromadb_private_subnet_id" {
  description = "ChromaDB private subnet ID"
  value       = aws_subnet.chromadb_private.id
}

output "rds_private_subnet_ids" {
  description = "List of RDS private subnet IDs"
  value       = aws_subnet.rds_private[*].id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

# Legacy outputs for backward compatibility
output "public_subnet_id" {
  description = "ID of the first public subnet (for backward compatibility)"
  value       = aws_subnet.public[0].id
}

output "private_subnet_ids" {
  description = "List of all private subnet IDs (for backward compatibility)"
  value       = concat(
    aws_subnet.frontend_private[*].id,
    aws_subnet.backend_private[*].id,
    [aws_subnet.chromadb_private.id],
    aws_subnet.rds_private[*].id
  )
}

output "private_subnet_id" {
  description = "ID of the first private subnet (for backward compatibility)"
  value       = aws_subnet.chromadb_private.id
}

# Legacy output for single RDS subnet (backward compatibility)
output "rds_private_subnet_id" {
  description = "ID of the first RDS private subnet (for backward compatibility)"
  value       = aws_subnet.rds_private[0].id
}
