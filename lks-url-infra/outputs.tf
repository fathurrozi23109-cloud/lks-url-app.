output "alb_dns_name" {
  description = "Buka http://<alb_dns_name> di browser"
  value       = module.alb.alb_dns_name
}

output "ecr_repository_urls" {
  value = module.ecr.repository_urls
}

output "rds_endpoint" {
  value = module.data.db_address
}

output "sqs_url" {
  value = module.data.sqs_url
}
