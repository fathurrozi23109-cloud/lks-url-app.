data "aws_caller_identity" "me" {}

module "network" {
  source = "./modules/network"
}

module "security" {
  source = "./modules/security"
  vpc_id = module.network.vpc_id
}

module "data" {
  source             = "./modules/data"
  private_subnet_ids = module.network.private_subnet_ids
  rds_sg_id          = module.security.rds_sg_id
  db_password        = var.db_password
}

module "ecr" {
  source = "./modules/ecr"
}

module "alb" {
  source            = "./modules/alb"
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  alb_sg_id         = module.security.alb_sg_id
}

module "ssm" {
  source         = "./modules/ssm"
  db_url         = "postgresql://${module.data.db_username}:${urlencode(var.db_password)}@${module.data.db_address}:5432/${module.data.db_name}"
  sqs_url        = module.data.sqs_url
  base_url       = "http://${module.alb.alb_dns_name}"
  dynamodb_table = module.data.dynamodb_table_name
  aws_region     = var.aws_region
}

module "ecs" {
  source             = "./modules/ecs"
  aws_region         = var.aws_region
  private_subnet_ids = module.network.private_subnet_ids
  ecs_sg_id          = module.security.ecs_sg_id
  target_group_arns  = module.alb.target_group_arns
  ecr_urls           = module.ecr.repository_urls
  ssm_arns           = module.ssm.parameter_arns

  # pastikan listener + rules sudah ada sebelum service dibuat
  depends_on = [module.alb]
}
