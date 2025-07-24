variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets (NAT Gateway + ALB)"
  type        = list(string)
}

variable "frontend_subnet_cidrs" {
  description = "List of CIDR blocks for frontend private subnets"
  type        = list(string)
}

variable "backend_subnet_cidrs" {
  description = "List of CIDR blocks for backend private subnets"
  type        = list(string)
}

variable "chromadb_subnet_cidr" {
  description = "CIDR block for ChromaDB private subnet"
  type        = string
}

variable "rds_subnet_cidr" {
  description = "CIDR block for RDS private subnet (AZ1)"
  type        = string
}

variable "rds_subnet_2_cidr" {
  description = "CIDR block for RDS private subnet (AZ2)"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}
