output "db_address" { value = aws_db_instance.db.address }
output "db_name" { value = aws_db_instance.db.db_name }
output "db_username" { value = aws_db_instance.db.username }
output "dynamodb_table_name" { value = aws_dynamodb_table.cache.name }
output "sqs_url" { value = aws_sqs_queue.main.url }
