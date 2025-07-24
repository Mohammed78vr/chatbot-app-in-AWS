# Security Group for Internal Backend ALB
resource "aws_security_group" "backend_alb_sg" {
  name        = "chatbot-backend-alb-sg"
  description = "Security group for chatbot internal backend ALB"
  vpc_id      = var.vpc_id

  # FastAPI access from frontend ASG security group
  ingress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [var.frontend_security_group_id]
    description     = "FastAPI access from frontend ASG"
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
    Name = "chatbot-backend-alb-sg"
  })
}

# Internal Application Load Balancer for Backend
resource "aws_lb" "backend_alb" {
  name               = "chatbot-backend-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.backend_alb_sg.id]
  subnets            = var.private_subnet_ids

  enable_deletion_protection = false

  tags = merge(var.tags, {
    Name = "chatbot-backend-alb"
  })
}

# Target Group for Backend FastAPI
resource "aws_lb_target_group" "backend_tg" {
  name     = "chatbot-backend-tg"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  
  health_check {
    enabled             = true
    interval            = 30
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    matcher             = "200-399"
  }

  tags = merge(var.tags, {
    Name = "chatbot-backend-tg"
  })
}

# HTTP Listener for Backend
resource "aws_lb_listener" "backend_http" {
  load_balancer_arn = aws_lb.backend_alb.arn
  port              = 5000
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}
