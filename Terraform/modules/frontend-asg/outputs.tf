output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.frontend_asg.name
}

output "asg_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.frontend_asg.arn
}

output "launch_template_id" {
  description = "ID of the Launch Template"
  value       = aws_launch_template.frontend_lt.id
}
