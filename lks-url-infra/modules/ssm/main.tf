locals {
  names = [
    "db-url", "sqs-url", "base-url", "port-api",
    "port-analytics", "dynamodb-table", "dynamodb-region",
  ]

  values = {
    "db-url"          = var.db_url
    "sqs-url"         = var.sqs_url
    "base-url"        = var.base_url
    "port-api"        = "3000"
    "port-analytics"  = "3001"
    "dynamodb-table"  = var.dynamodb_table
    "dynamodb-region" = var.aws_region
  }
}

resource "aws_ssm_parameter" "p" {
  for_each = toset(local.names)
  name     = "/lks-url/${each.key}"
  type     = each.key == "db-url" ? "SecureString" : "String"
  value    = local.values[each.key]
  tags     = { Name = "lks-url-${each.key}" }
}
