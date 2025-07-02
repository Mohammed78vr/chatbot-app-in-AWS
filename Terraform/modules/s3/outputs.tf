output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.chatbot_bucket.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.chatbot_bucket.arn
}

output "bucket_id" {
  description = "ID of the S3 bucket"
  value       = aws_s3_bucket.chatbot_bucket.id
}
