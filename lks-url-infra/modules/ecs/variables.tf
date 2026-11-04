variable "aws_region" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "ecs_sg_id" { type = string }
variable "target_group_arns" { type = map(string) }
variable "ecr_urls" { type = map(string) }
variable "ssm_arns" { type = map(string) }
