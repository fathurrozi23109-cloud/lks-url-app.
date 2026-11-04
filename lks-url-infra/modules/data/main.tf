# ---------------- RDS PostgreSQL 17 ----------------
resource "aws_db_subnet_group" "db" {
  name       = "lks-url-db-subnet-group"
  subnet_ids = var.private_subnet_ids
  tags       = { Name = "lks-url-db-subnet-group" }
}

resource "aws_db_instance" "db" {
  identifier             = "lks-url-db"
  engine                 = "postgres"
  engine_version         = "17"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  db_name                = "urlshortener"
  username               = "urlshortener"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.db.name
  vpc_security_group_ids = [var.rds_sg_id]
  publicly_accessible    = false
  multi_az               = false
  skip_final_snapshot    = true
  apply_immediately      = true
  tags                   = { Name = "lks-url-db" }
}

# ---------------- DynamoDB ----------------
resource "aws_dynamodb_table" "cache" {
  name         = "lks-url-cache-table"
  billing_mode = "PAY_PER_REQUEST"
  table_class  = "STANDARD"
  hash_key     = "code"

  attribute {
    name = "code"
    type = "S"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }
  tags = { Name = "lks-url-cache-table" }
}

# ---------------- SQS + DLQ ----------------
resource "aws_sqs_queue" "dlq" {
  name                      = "lks-url-click-events-dlq"
  message_retention_seconds = 432000 # 5 hari
  tags                      = { Name = "lks-url-click-events-dlq" }
}

resource "aws_sqs_queue" "main" {
  name                       = "lks-url-click-events"
  visibility_timeout_seconds = 30
  message_retention_seconds  = 86400 # 1 hari
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 5
  })
  tags = { Name = "lks-url-click-events" }
}
