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
  
  vpc_cidr               = var.vpc_cidr
  availability_zones     = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  public_subnet_cidrs    = [var.public_subnet_cidr, var.public_subnet_2_cidr]
  frontend_subnet_cidrs  = [var.frontend_subnet_1_cidr, var.frontend_subnet_2_cidr]
  backend_subnet_cidrs   = [var.backend_subnet_1_cidr, var.backend_subnet_2_cidr]
  chromadb_subnet_cidr   = var.chromadb_subnet_cidr
  rds_subnet_cidr        = var.rds_subnet_cidr
  rds_subnet_2_cidr      = var.rds_subnet_2_cidr
  project_name           = var.project_name
  environment            = var.environment
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

# Frontend ALB Module (Internet-facing)
module "frontend_alb" {
  source = "./modules/frontend-alb"
  
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  tags              = var.common_tags
}

# Backend ALB Module (Internal)
module "backend_alb" {
  source = "./modules/backend-alb"
  
  vpc_id                     = module.vpc.vpc_id
  private_subnet_ids         = module.vpc.backend_private_subnet_ids
  frontend_security_group_id = aws_security_group.frontend_sg.id
  tags                       = var.common_tags
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

  # ChromaDB access from backend ASG instances
  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_sg.id]
    description     = "ChromaDB access from backend ASG instances"
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

# Security Group for Frontend ASG instances
resource "aws_security_group" "frontend_sg" {
  name        = "chatbot-frontend-sg"
  description = "Security group for chatbot frontend ASG instances"
  vpc_id      = module.vpc.vpc_id

  # Streamlit access from ALB only
  ingress {
    from_port       = 8501
    to_port         = 8501
    protocol        = "tcp"
    security_groups = [module.frontend_alb.alb_security_group_id]
    description     = "Streamlit access from ALB"
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
    Name = "chatbot-frontend-sg"
  })
}

# Security Group for Backend ASG instances
resource "aws_security_group" "backend_sg" {
  name        = "chatbot-backend-sg"
  description = "Security group for chatbot backend ASG instances"
  vpc_id      = module.vpc.vpc_id

  # SSH access for management
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Consider restricting this to specific IPs or a bastion host
    description = "SSH access"
  }

  # FastAPI access from internal backend ALB
  ingress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [module.backend_alb.backend_alb_security_group_id]
    description     = "FastAPI access from internal backend ALB"
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
    Name = "chatbot-backend-sg"
  })
}

# ChromaDB EC2 Module
module "chromadb_ec2" {
  source = "./modules/chromadb-ec2"
  
  vpc_id                = module.vpc.vpc_id
  private_subnet_id     = module.vpc.chromadb_private_subnet_id
  iam_role_name         = module.iam.chromadb_instance_profile_name
  security_group_id     = aws_security_group.chromadb_sg.id
  
  instance_type = var.chromadb_instance_type
  key_name      = var.key_name
  
  tags = var.common_tags
}

# RDS Module
module "rds" {
  source = "./modules/rds"
  
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.rds_private_subnet_ids
  ec2_security_group_id = aws_security_group.backend_sg.id
  
  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password
  
  tags = var.common_tags
}

# Add bidirectional security group rule after both security groups are created
resource "aws_security_group_rule" "backend_from_rds" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = module.rds.rds_security_group_id
  security_group_id        = aws_security_group.backend_sg.id
  description              = "PostgreSQL access from RDS"
}

# Frontend ASG Module
module "frontend_asg" {
  source = "./modules/frontend-asg"
  
  vpc_id                   = module.vpc.vpc_id
  private_subnet_ids       = module.vpc.frontend_private_subnet_ids
  security_group_id        = aws_security_group.frontend_sg.id
  target_group_arn         = module.frontend_alb.target_group_arn
  instance_type            = var.app_instance_type
  key_name                 = var.key_name
  iam_instance_profile_name = module.iam.frontend_instance_profile_name
  custom_ami_id            = var.frontend_ami_id != "" ? var.frontend_ami_id : var.custom_ami_id
  min_size                 = var.asg_min_size
  max_size                 = var.asg_max_size
  desired_capacity         = var.asg_desired_capacity
  secret_name              = var.secret_name
  region                   = var.aws_region
  backend_alb_dns_name     = module.backend_alb.backend_alb_dns_name
  tags                     = var.common_tags
}

# Backend ASG Module
module "backend_asg" {
  source = "./modules/backend-asg"
  
  vpc_id                   = module.vpc.vpc_id
  private_subnet_ids       = module.vpc.backend_private_subnet_ids
  security_group_id        = aws_security_group.backend_sg.id
  target_group_arn         = module.backend_alb.backend_target_group_arn
  instance_type            = var.app_instance_type
  key_name                 = var.key_name
  iam_instance_profile_name = module.iam.instance_profile_name
  custom_ami_id            = var.custom_ami_id
  min_size                 = var.asg_min_size
  max_size                 = var.asg_max_size
  desired_capacity         = var.asg_desired_capacity
  chromadb_host            = module.chromadb_ec2.private_ip
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
  chromadb_host    = module.chromadb_ec2.private_ip
  chromadb_port    = var.chromadb_port
  backend_alb_dns_name = module.backend_alb.backend_alb_dns_name
  
  tags = var.common_tags
}
