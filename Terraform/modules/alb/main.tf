# Security Group for ALB
resource "aws_security_group" "alb_sg" {
  name        = "chatbot-alb-sg"
  description = "Security group for chatbot ALB"
  vpc_id      = var.vpc_id

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }

  # HTTPS access from anywhere (if you add SSL certificate)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access"
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
    Name = "chatbot-alb-sg"
  })
}

# Application Load Balancer
resource "aws_lb" "chatbot_alb" {
  name               = "chatbot-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = merge(var.tags, {
    Name = "chatbot-alb"
  })
}

# Target Group for Streamlit
resource "aws_lb_target_group" "streamlit_tg" {
  name     = "chatbot-streamlit-tg"
  port     = 8501
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  
  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    matcher             = "200-399"
  }

  tags = merge(var.tags, {
    Name = "chatbot-streamlit-tg"
  })
}

# HTTP Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.chatbot_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.streamlit_tg.arn
  }
}

# HTTPS Listener (commented out - uncomment and configure when you have an SSL certificate)
# resource "aws_lb_listener" "https" {
#   load_balancer_arn = aws_lb.chatbot_alb.arn
#   port              = 443
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = var.certificate_arn
#
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.streamlit_tg.arn
#   }
# }
