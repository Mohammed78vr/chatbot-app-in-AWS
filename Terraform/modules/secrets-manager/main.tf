# AWS Secrets Manager Secret
resource "aws_secretsmanager_secret" "chatbot_secrets" {
  name                    = var.secret_name
  description             = "Secrets for Chatbot Application"
  recovery_window_in_days = 7

  tags = var.tags
}

# AWS Secrets Manager Secret Version
resource "aws_secretsmanager_secret_version" "chatbot_secrets_version" {
  secret_id = aws_secretsmanager_secret.chatbot_secrets.id
  secret_string = jsonencode({
    "PROJ-DB-NAME"         = var.db_name
    "PROJ-DB-USER"         = var.db_username
    "PROJ-DB-PASSWORD"     = var.db_password
    "PROJ-DB-HOST"         = split(":", var.db_host)[0]  # Remove port from host
    "PROJ-DB-PORT"         = var.db_port
    "PROJ-OPENAI-API-KEY"  = var.openai_api_key
    "PROJ-S3-BUCKET-NAME"  = var.s3_bucket_name
    "PROJ-CHROMADB-HOST"   = var.chromadb_host
    "PROJ-CHROMADB-PORT"   = var.chromadb_port
  })

  lifecycle {
    ignore_changes = [
      secret_string
    ]
  }
}
