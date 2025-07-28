variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "chatbot"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for first public subnet (NAT Gateway + ALB - AZ1)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for second public subnet (ALB - AZ2)"
  type        = string
  default     = "10.0.2.0/24"
}

variable "frontend_subnet_1_cidr" {
  description = "CIDR block for frontend private subnet (AZ1)"
  type        = string
  default     = "10.0.3.0/24"
}

variable "frontend_subnet_2_cidr" {
  description = "CIDR block for frontend private subnet (AZ2)"
  type        = string
  default     = "10.0.4.0/24"
}

variable "backend_subnet_1_cidr" {
  description = "CIDR block for backend private subnet (Internal ALB + ASG - AZ1)"
  type        = string
  default     = "10.0.5.0/24"
}

variable "backend_subnet_2_cidr" {
  description = "CIDR block for backend private subnet (Internal ALB + ASG - AZ2)"
  type        = string
  default     = "10.0.6.0/24"
}

variable "chromadb_subnet_cidr" {
  description = "CIDR block for ChromaDB private subnet (AZ1)"
  type        = string
  default     = "10.0.7.0/24"
}

variable "rds_subnet_cidr" {
  description = "CIDR block for RDS private subnet (AZ1)"
  type        = string
  default     = "10.0.8.0/24"
}

variable "rds_subnet_2_cidr" {
  description = "CIDR block for RDS private subnet (AZ2)"
  type        = string
  default     = "10.0.9.0/24"
}

variable "chromadb_instance_type" {
  description = "EC2 instance type for ChromaDB"
  type        = string
  default     = "t2.large"
}

variable "app_instance_type" {
  description = "EC2 instance type for application instances in ASG"
  type        = string
  default     = "t2.large"
}

variable "key_name" {
  description = "AWS Key Pair name for EC2 access"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name for S3 bucket"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "chatbotdb"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "secret_name" {
  description = "Name for AWS Secrets Manager secret"
  type        = string
  default     = "chatbot-secrets"
}

variable "openai_api_key" {
  description = "OpenAI API Key"
  type        = string
  sensitive   = true
  default     = "placeholder-openai-key"
}

variable "chromadb_port" {
  description = "ChromaDB port"
  type        = string
  default     = "8000"
}

variable "custom_ami_id" {
  description = "Custom AMI ID for ASG instances (optional)"
  type        = string
  default     = ""
}

variable "chromadb_ami_id" {
  description = "Custom AMI ID for ChromaDB instance (optional)"
  type        = string
  default     = ""
}

variable "frontend_ami_id" {
  description = "Custom AMI ID for frontend ASG instances (optional)"
  type        = string
  default     = ""
}

variable "asg_min_size" {
  description = "Minimum size of the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Maximum size of the Auto Scaling Group"
  type        = number
  default     = 3
}

variable "asg_desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "ChatbotApp"
    Environment = "dev"
  }
}
