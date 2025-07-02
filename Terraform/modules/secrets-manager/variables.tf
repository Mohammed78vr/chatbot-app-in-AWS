variable "secret_name" {
  description = "Name of the AWS Secrets Manager secret"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_host" {
  description = "Database host"
  type        = string
}

variable "db_port" {
  description = "Database port"
  type        = string
  default     = "5432"
}

variable "openai_api_key" {
  description = "OpenAI API Key"
  type        = string
  sensitive   = true
  default     = "placeholder-openai-key"
}

variable "s3_bucket_name" {
  description = "S3 bucket name"
  type        = string
}

variable "chromadb_host" {
  description = "ChromaDB host"
  type        = string
  default     = "localhost"
}

variable "chromadb_port" {
  description = "ChromaDB port"
  type        = string
  default     = "8000"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
