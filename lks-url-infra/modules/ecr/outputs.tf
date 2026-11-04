output "repository_urls" {
  value = { for k, r in aws_ecr_repository.repo : replace(k, "lks-url-", "") => r.repository_url }
}
