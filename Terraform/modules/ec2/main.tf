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

# EC2 Instance for ChromaDB
resource "aws_instance" "chromadb_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [var.security_group_id]
  subnet_id              = var.private_subnet_id
  iam_instance_profile   = var.iam_role_name

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    is_chromadb_only = true
  }))

  tags = merge(var.tags, {
    Name = "chromadb-ec2-instance"
  })
}
