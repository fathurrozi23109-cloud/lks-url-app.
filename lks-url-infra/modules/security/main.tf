resource "aws_security_group" "alb" {
  name        = "lks-url-alb-sg"
  description = "ALB: allow HTTP from internet"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "lks-url-alb-sg" }
}

resource "aws_security_group" "ecs" {
  name        = "lks-url-ecs-sg"
  description = "ECS: only from ALB"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = [80, 3000, 3001]
    content {
      from_port       = ingress.value
      to_port         = ingress.value
      protocol        = "tcp"
      security_groups = [aws_security_group.alb.id]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "lks-url-ecs-sg" }
}

resource "aws_security_group" "rds" {
  name        = "lks-url-rds-sg"
  description = "RDS: only PostgreSQL from ECS"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }
  tags = { Name = "lks-url-rds-sg" }
}
