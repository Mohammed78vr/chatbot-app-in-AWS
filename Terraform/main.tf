terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data source to get available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr             = var.vpc_cidr
  availability_zones   = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  public_subnet_cidrs  = [var.public_subnet_cidr, var.public_subnet_2_cidr]
  private_subnet_cidr  = [var.private_subnet_cidr, var.private_subnet_2_cidr, var.private_subnet_3_cidr, var.private_subnet_4_cidr]
  project_name         = var.project_name
  environment          = var.environment
}

# S3 Module
module "s3" {
  source = "./modules/s3"
  
  bucket_name = var.s3_bucket_name
  tags        = var.common_tags
}

# IAM Module
module "iam" {
  source = "./modules/iam"
  
  s3_bucket_arn        = module.s3.bucket_arn
  secrets_manager_arn  = module.secrets_manager.secret_arn
  tags                 = var.common_tags
}

# ALB Module
module "alb" {
  source = "./modules/alb"
  
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  tags              = var.common_tags
}

# Security Group for ChromaDB EC2
resource "aws_security_group" "chromadb_sg" {
  name        = "chromadb-ec2-sg"
  description = "Security group for ChromaDB EC2 instance"
  vpc_id      = module.vpc.vpc_id

  # SSH access from bastion or VPN (for maintenance)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Consider restricting this to specific IPs or a bastion host
    description = "SSH access for maintenance"
  }

  # ChromaDB access from ASG instances
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = [var.private_subnet_3_cidr, var.private_subnet_4_cidr]
    description = "ChromaDB access from ASG instances"
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(var.common_tags, {
    Name = "chromadb-ec2-sg"
  })
}

# Security Group for ASG instances
resource "aws_security_group" "asg_sg" {
  name        = "chatbot-asg-sg"
  description = "Security group for chatbot ASG instances"
  vpc_id      = module.vpc.vpc_id

  # SSH access for management
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Consider restricting this to specific IPs or a bastion host
    description = "SSH access"
  }

  # Streamlit access from ALB only
  ingress {
    from_port       = 8501
    to_port         = 8501
    protocol        = "tcp"
    security_groups = [module.alb.alb_security_group_id]
    description     = "Streamlit access from ALB"
  }

  # FastAPI access from within the security group
  ingress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    self            = true
    description     = "FastAPI access from within the security group"
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(var.common_tags, {
    Name = "chatbot-asg-sg"
  })
}

# EC2 Module for ChromaDB
module "ec2" {
  source = "./modules/ec2"
  
  vpc_id                = module.vpc.vpc_id
  private_subnet_id     = module.vpc.private_subnet_ids[0]
  iam_role_name         = module.iam.instance_profile_name
  security_group_id     = aws_security_group.chromadb_sg.id
  
  instance_type = var.chromadb_instance_type
  key_name      = var.key_name
  
  tags = var.common_tags
}

# RDS Module
module "rds" {
  source = "./modules/rds"
  
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = [module.vpc.private_subnet_ids[0], module.vpc.private_subnet_ids[1]]
  ec2_security_group_id = aws_security_group.asg_sg.id
  
  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password
  
  tags = var.common_tags
}

# Add bidirectional security group rule after both security groups are created
resource "aws_security_group_rule" "asg_from_rds" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = module.rds.rds_security_group_id
  security_group_id        = aws_security_group.asg_sg.id
  description              = "PostgreSQL access from RDS"
}

# ASG Module
module "asg" {
  source = "./modules/asg"
  
  vpc_id                   = module.vpc.vpc_id
  private_subnet_ids       = [module.vpc.private_subnet_ids[2], module.vpc.private_subnet_ids[3]]
  security_group_id        = aws_security_group.asg_sg.id
  target_group_arn         = module.alb.target_group_arn
  instance_type            = var.app_instance_type
  key_name                 = var.key_name
  iam_instance_profile_name = module.iam.instance_profile_name
  custom_ami_id            = var.custom_ami_id
  min_size                 = var.asg_min_size
  max_size                 = var.asg_max_size
  desired_capacity         = var.asg_desired_capacity
  chromadb_host            = module.ec2.private_ip
  chromadb_port            = var.chromadb_port
  secret_name              = var.secret_name
  region                   = var.aws_region
  tags                     = var.common_tags
}

# Secrets Manager Module
module "secrets_manager" {
  source = "./modules/secrets-manager"
  
  secret_name       = var.secret_name
  db_name          = var.db_name
  db_username      = var.db_username
  db_password      = var.db_password
  db_host          = module.rds.db_endpoint
  db_port          = tostring(module.rds.db_port)
  openai_api_key   = var.openai_api_key
  s3_bucket_name   = var.s3_bucket_name
  chromadb_host    = module.ec2.private_ip
  chromadb_port    = var.chromadb_port
  
  tags = var.common_tags
}
