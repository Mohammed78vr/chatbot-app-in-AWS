variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_id" {
  description = "ID of the private subnet for ChromaDB instance"
  type        = string
}

variable "iam_role_name" {
  description = "Name of the IAM instance profile"
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

variable "security_group_id" {
  description = "Security group ID for the ChromaDB instance"
  type        = string
}

variable "custom_ami_id" {
  description = "Custom AMI ID for ChromaDB instance (optional)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
