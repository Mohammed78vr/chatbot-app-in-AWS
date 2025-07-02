# IAM Role for EC2 to access S3 and Secrets Manager
resource "aws_iam_role" "ec2_s3_role" {
  name = "chatbot-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM Policy for S3 access
resource "aws_iam_policy" "s3_access_policy" {
  name        = "chatbot-s3-access-policy"
  description = "Policy for EC2 to access S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          var.s3_bucket_arn,
          "${var.s3_bucket_arn}/*"
        ]
      }
    ]
  })

  tags = var.tags
}

# IAM Policy for Secrets Manager access
resource "aws_iam_policy" "secrets_manager_policy" {
  name        = "chatbot-secrets-manager-policy"
  description = "Policy for EC2 to access Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = var.secrets_manager_arn
      }
    ]
  })

  tags = var.tags
}

# Attach S3 policy to role
resource "aws_iam_role_policy_attachment" "ec2_s3_policy_attachment" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

# Attach Secrets Manager policy to role
resource "aws_iam_role_policy_attachment" "ec2_secrets_manager_policy_attachment" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = aws_iam_policy.secrets_manager_policy.arn
}

# Attach AWS managed SSM policies to role
resource "aws_iam_role_policy_attachment" "ec2_ssm_managed_instance_core" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_full_access" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

# Instance profile for EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "chatbot-ec2-profile"
  role = aws_iam_role.ec2_s3_role.name

  tags = var.tags
}
