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

# Launch Template for Backend ASG
resource "aws_launch_template" "chatbot_lt" {
  name_prefix   = "backend-chatbot-lt-"
  image_id      = var.custom_ami_id != "" ? var.custom_ami_id : data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.security_group_id]
    delete_on_termination       = true
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    secret_name   = var.secret_name
    region        = var.region
  }))

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = "backend-chatbot-instance"
      Type = "Backend"
    })
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Backend Auto Scaling Group
resource "aws_autoscaling_group" "chatbot_asg" {
  name                = "backend-chatbot-asg"
  vpc_zone_identifier = var.private_subnet_ids
  desired_capacity    = var.desired_capacity
  min_size            = var.min_size
  max_size            = var.max_size
  target_group_arns   = [var.target_group_arn]
  health_check_type   = "ELB"
  
  launch_template {
    id      = aws_launch_template.chatbot_lt.id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = merge(var.tags, {
      Name = "backend-chatbot-instance"
      Type = "Backend"
    })
    
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}