resource "aws_ecr_repository" "repo" {
  for_each             = toset(["lks-url-api", "lks-url-analytics", "lks-url-frontend"])
  name                 = each.key
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = false
  }
  tags = { Name = each.key }
}
