# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc-${var.environment}"
    Project = var.project_name
    Environment = var.environment
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw-${var.environment}"
    Project = var.project_name
    Environment = var.environment
  }
}

# Public Subnets (2 AZs) - NAT Gateway + Internet-facing ALB
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet-${count.index + 1}-${var.environment}"
    Type = "Public"
    Purpose = count.index == 0 ? "NAT-Gateway-ALB" : "ALB"
    Project = var.project_name
    Environment = var.environment
  }
}

# Frontend Private Subnets (2 AZs)
resource "aws_subnet" "frontend_private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.frontend_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.project_name}-frontend-private-subnet-${count.index + 1}-${var.environment}"
    Type = "Private"
    Purpose = "Frontend-ASG"
    Project = var.project_name
    Environment = var.environment
  }
}

# Backend Private Subnets (2 AZs)
resource "aws_subnet" "backend_private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.backend_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.project_name}-backend-private-subnet-${count.index + 1}-${var.environment}"
    Type = "Private"
    Purpose = "Backend-ALB-ASG"
    Project = var.project_name
    Environment = var.environment
  }
}

# ChromaDB Private Subnet (AZ1 only)
resource "aws_subnet" "chromadb_private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.chromadb_subnet_cidr
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "${var.project_name}-chromadb-private-subnet-${var.environment}"
    Type = "Private"
    Purpose = "ChromaDB"
    Project = var.project_name
    Environment = var.environment
  }
}

# RDS Private Subnets (2 AZs for DB Subnet Group requirement)
resource "aws_subnet" "rds_private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = count.index == 0 ? var.rds_subnet_cidr : var.rds_subnet_2_cidr
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.project_name}-rds-private-subnet-${count.index + 1}-${var.environment}"
    Type = "Private"
    Purpose = "RDS-Database"
    Project = var.project_name
    Environment = var.environment
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip-${var.environment}"
    Project = var.project_name
    Environment = var.environment
  }
}

# NAT Gateway in first public subnet
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.project_name}-nat-gateway-${var.environment}"
    Project = var.project_name
    Environment = var.environment
  }

  depends_on = [aws_internet_gateway.main]
}

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt-${var.environment}"
    Project = var.project_name
    Environment = var.environment
  }
}

# Route Table for Private Subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-private-rt-${var.environment}"
    Project = var.project_name
    Environment = var.environment
  }
}

# Public Route Table Associations
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Frontend Private Route Table Associations
resource "aws_route_table_association" "frontend_private" {
  count          = length(aws_subnet.frontend_private)
  subnet_id      = aws_subnet.frontend_private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Backend Private Route Table Associations
resource "aws_route_table_association" "backend_private" {
  count          = length(aws_subnet.backend_private)
  subnet_id      = aws_subnet.backend_private[count.index].id
  route_table_id = aws_route_table.private.id
}

# ChromaDB Private Route Table Association
resource "aws_route_table_association" "chromadb_private" {
  subnet_id      = aws_subnet.chromadb_private.id
  route_table_id = aws_route_table.private.id
}

# RDS Private Route Table Associations
resource "aws_route_table_association" "rds_private" {
  count          = length(aws_subnet.rds_private)
  subnet_id      = aws_subnet.rds_private[count.index].id
  route_table_id = aws_route_table.private.id
}
