output "role_arn" {
  description = "ARN of the IAM role"
  value       = aws_iam_role.ec2_s3_role.arn
}

output "instance_profile_name" {
  description = "Name of the instance profile"
  value       = aws_iam_instance_profile.ec2_profile.name
}

output "frontend_instance_profile_name" {
  description = "Name of the frontend instance profile"
  value       = aws_iam_instance_profile.frontend_profile.name
}

output "chromadb_instance_profile_name" {
  description = "Name of the ChromaDB instance profile"
  value       = aws_iam_instance_profile.chromadb_profile.name
}

output "policy_arn" {
  description = "ARN of the S3 access policy"
  value       = aws_iam_policy.s3_access_policy.arn
}
