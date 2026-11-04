variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "db_password" {
  description = "Master password for RDS (diisi dari secret DB_PASSWORD)"
  type        = string
  sensitive   = true
}
