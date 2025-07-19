variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs of the public subnets for the ALB"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Uncomment when you have an SSL certificate
# variable "certificate_arn" {
#   description = "ARN of the SSL certificate for HTTPS"
#   type        = string
#   default     = ""
# }
