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
  public_subnet_cidrs  = [var.public_subnet_cidr]
  private_subnet_cidr  = [var.private_subnet_cidr, var.private_subnet_2_cidr]
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
  
  s3_bucket_arn = module.s3.bucket_arn
  tags          = var.common_tags
}

# EC2 Module (moved before RDS to resolve dependency)
module "ec2" {
  source = "./modules/ec2"
  
  vpc_id           = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_id
  iam_role_name    = module.iam.instance_profile_name
  
  instance_type = var.instance_type
  key_name      = var.key_name
  
  tags = var.common_tags
}

# RDS Module
module "rds" {
  source = "./modules/rds"
  
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  ec2_security_group_id = module.ec2.security_group_id
  
  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password
  
  tags = var.common_tags
}
