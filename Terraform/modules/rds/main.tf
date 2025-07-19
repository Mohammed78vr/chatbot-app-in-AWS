# Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "chatbot-rds-sg"
  description = "Security group for chatbot RDS instance"
  vpc_id      = var.vpc_id

  # PostgreSQL access from ASG instances
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.ec2_security_group_id]
    description     = "PostgreSQL access from ASG instances"
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(var.tags, {
    Name = "chatbot-rds-sg"
  })
}

# DB Subnet Group
resource "aws_db_subnet_group" "chatbot_db_subnet_group" {
  name       = "chatbot-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.tags, {
    Name = "chatbot-db-subnet-group"
  })
}

# RDS Instance
resource "aws_db_instance" "chatbot_db" {
  identifier = "chatbot-postgres-db"

  # Engine configuration
  engine         = "postgres"
  engine_version = "16.8"
  instance_class = "db.t3.micro"

  # Storage configuration
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp2"
  storage_encrypted     = true

  # Database configuration
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  # Network configuration
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.chatbot_db_subnet_group.name
  publicly_accessible    = false

  # Backup configuration
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"

  # Other settings
  skip_final_snapshot = true
  deletion_protection = false

  # Enable automatic minor version upgrades
  auto_minor_version_upgrade = true

  # Enable performance insights for monitoring
  performance_insights_enabled = true

  tags = merge(var.tags, {
    Name = "chatbot-postgres-db"
  })
}
