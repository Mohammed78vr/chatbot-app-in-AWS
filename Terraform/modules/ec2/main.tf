# Get latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group for EC2
resource "aws_security_group" "ec2_sg" {
  name        = "chatbot-ec2-sg"
  description = "Security group for chatbot EC2 instance"
  vpc_id      = var.vpc_id

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  # Streamlit access
  ingress {
    from_port   = 8501
    to_port     = 8501
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Streamlit access"
  }



  # All outbound traffic (required for SSM and other services)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic (required for SSM, package updates, etc.)"
  }

  tags = merge(var.tags, {
    Name = "chatbot-ec2-sg"
  })
}

# EC2 Instance
resource "aws_instance" "chatbot_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  subnet_id              = var.public_subnet_id
  iam_instance_profile   = var.iam_role_name

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {}))

  tags = merge(var.tags, {
    Name = "chatbot-ec2-instance"
  })
}
