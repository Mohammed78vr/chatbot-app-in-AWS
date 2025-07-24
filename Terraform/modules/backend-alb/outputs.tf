output "backend_alb_dns_name" {
  description = "DNS name of the backend Application Load Balancer"
  value       = aws_lb.backend_alb.dns_name
}

output "backend_alb_zone_id" {
  description = "Zone ID of the backend Application Load Balancer"
  value       = aws_lb.backend_alb.zone_id
}

output "backend_alb_arn" {
  description = "ARN of the backend Application Load Balancer"
  value       = aws_lb.backend_alb.arn
}

output "backend_target_group_arn" {
  description = "ARN of the backend target group"
  value       = aws_lb_target_group.backend_tg.arn
}

output "backend_alb_security_group_id" {
  description = "ID of the backend ALB security group"
  value       = aws_security_group.backend_alb_sg.id
}
