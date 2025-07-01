resource "aws_s3_bucket" "chatbot_bucket" {
  bucket = var.bucket_name

  tags = merge(var.tags, {
    Name = "chatbot-s3-bucket"
  })
}

resource "aws_s3_bucket_versioning" "chatbot_bucket_versioning" {
  bucket = aws_s3_bucket.chatbot_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "chatbot_bucket_encryption" {
  bucket = aws_s3_bucket.chatbot_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "chatbot_bucket_pab" {
  bucket = aws_s3_bucket.chatbot_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
