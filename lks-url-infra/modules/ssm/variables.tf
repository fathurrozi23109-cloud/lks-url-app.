variable "db_url" {
  type      = string
  sensitive = true
}
variable "sqs_url" { type = string }
variable "base_url" { type = string }
variable "dynamodb_table" { type = string }
variable "aws_region" { type = string }
