output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "frontend_private_subnet_ids" {
  description = "IDs of the frontend private subnets"
  value       = module.vpc.frontend_private_subnet_ids
}

output "backend_private_subnet_ids" {
  description = "IDs of the backend private subnets"
  value       = module.vpc.backend_private_subnet_ids
}

output "chromadb_private_subnet_id" {
  description = "ID of the ChromaDB private subnet"
  value       = module.vpc.chromadb_private_subnet_id
}

output "rds_private_subnet_ids" {
  description = "IDs of the RDS private subnets"
  value       = module.vpc.rds_private_subnet_ids
}

# Legacy output for backward compatibility
output "rds_private_subnet_id" {
  description = "ID of the first RDS private subnet (for backward compatibility)"
  value       = module.vpc.rds_private_subnet_id
}

output "chromadb_instance_id" {
  description = "ID of the ChromaDB EC2 instance"
  value       = module.chromadb_ec2.instance_id
}

output "chromadb_private_ip" {
  description = "Private IP of the ChromaDB EC2 instance"
  value       = module.chromadb_ec2.private_ip
}

output "frontend_alb_dns_name" {
  description = "DNS name of the Frontend Application Load Balancer"
  value       = module.frontend_alb.alb_dns_name
}

output "backend_alb_dns_name" {
  description = "DNS name of the Backend Application Load Balancer"
  value       = module.backend_alb.backend_alb_dns_name
}

output "frontend_asg_name" {
  description = "Name of the Frontend Auto Scaling Group"
  value       = module.frontend_asg.asg_name
}

output "backend_asg_name" {
  description = "Name of the Backend Auto Scaling Group"
  value       = module.backend_asg.asg_name
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.db_endpoint
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.s3.bucket_name
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.s3.bucket_arn
}

output "secrets_manager_name" {
  description = "Name of the Secrets Manager secret"
  value       = module.secrets_manager.secret_name
}

output "secrets_manager_arn" {
  description = "ARN of the Secrets Manager secret"
  value       = module.secrets_manager.secret_arn
}

# Legacy outputs for backward compatibility
output "public_subnet_id" {
  description = "ID of the first public subnet (for backward compatibility)"
  value       = module.vpc.public_subnet_ids[0]
}

output "private_subnet_ids" {
  description = "List of all private subnet IDs (for backward compatibility)"
  value       = module.vpc.private_subnet_ids
}

output "alb_dns_name" {
  description = "DNS name of the Frontend Application Load Balancer (for backward compatibility)"
  value       = module.frontend_alb.alb_dns_name
}
