data "aws_iam_role" "lab" {
  name = "LabRole"
}

resource "aws_ecs_cluster" "cluster" {
  name = "lks-url-cluster"
  tags = { Name = "lks-url-cluster" }
}

locals {
  services = {
    api = {
      family    = "lks-url-api-td"
      container = "shorener-api"
      cpu       = 512
      memory    = 1024
      port      = 3000
      log_group = "/ecs/lks-url-shortener-api"
      prod      = true
    }
    analytics = {
      family    = "lks-url-analytics-td"
      container = "analytics-svc"
      cpu       = 512
      memory    = 1024
      port      = 3001
      log_group = "/ecs/lks-url-analytics"
      prod      = true
    }
    frontend = {
      family    = "lks-url-frontend-td"
      container = "frontend"
      cpu       = 256
      memory    = 512
      port      = 80
      log_group = "/ecs/lks-url-frontend"
      prod      = false
    }
  }

  # env var name -> SSM key (urutan/nama mengikuti README tiap service)
  backend_secrets = {
    DATABASE_URL    = "db-url"
    SQS_QUEUE_URL   = "sqs-url"
    BASE_URL        = "base-url"
    DYNAMODB_TABLE  = "dynamodb-table"
    DYNAMODB_REGION = "dynamodb-region"
  }
}

resource "aws_cloudwatch_log_group" "lg" {
  for_each          = local.services
  name              = each.value.log_group
  retention_in_days = 7
  tags              = { Name = each.value.log_group }
}

resource "aws_ecs_task_definition" "td" {
  for_each                 = local.services
  family                   = each.value.family
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = each.value.cpu
  memory                   = each.value.memory
  execution_role_arn       = data.aws_iam_role.lab.arn
  task_role_arn            = data.aws_iam_role.lab.arn

  container_definitions = jsonencode([{
    name         = each.value.container
    image        = "${var.ecr_urls[each.key]}:latest"
    essential    = true
    portMappings = [{ containerPort = each.value.port, protocol = "tcp" }]

    environment = each.value.prod ? [{ name = "NODE_ENV", value = "production" }] : []

    secrets = each.key == "frontend" ? [] : concat(
      [for env, key in local.backend_secrets : { name = env, valueFrom = var.ssm_arns[key] }],
      [{ name = "PORT", valueFrom = var.ssm_arns["port-${each.key}"] }]
    )

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = each.value.log_group
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "ecs"
      }
    }
  }])

  tags       = { Name = each.value.family }
  depends_on = [aws_cloudwatch_log_group.lg]
}

resource "aws_ecs_service" "svc" {
  for_each        = local.services
  name            = "lks-url-${each.key}-svc"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.td[each.key].arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_sg_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arns[each.key]
    container_name   = each.value.container
    container_port   = each.value.port
  }

  tags = { Name = "lks-url-${each.key}-svc" }
}
