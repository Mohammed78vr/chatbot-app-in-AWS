variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs of the private subnets for the frontend ASG"
  type        = list(string)
}

variable "security_group_id" {
  description = "ID of the security group for frontend ASG instances"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the target group"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.large"
}

variable "key_name" {
  description = "AWS Key Pair name"
  type        = string
}

variable "iam_instance_profile_name" {
  description = "Name of the IAM instance profile for frontend"
  type        = string
}

variable "custom_ami_id" {
  description = "Custom AMI ID (if provided)"
  type        = string
  default     = ""
}

variable "min_size" {
  description = "Minimum size of the ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum size of the ASG"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Desired capacity of the ASG"
  type        = number
  default     = 2
}

variable "secret_name" {
  description = "Name of the AWS Secrets Manager secret"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "backend_alb_dns_name" {
  description = "DNS name of the backend ALB"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
