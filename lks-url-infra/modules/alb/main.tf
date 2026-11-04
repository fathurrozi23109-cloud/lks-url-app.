resource "aws_lb" "alb" {
  name               = "lks-url-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids
  tags               = { Name = "lks-url-alb" }
}

locals {
  tgs = {
    frontend  = { port = 80, path = "/" }
    api       = { port = 3000, path = "/api/health" }
    analytics = { port = 3001, path = "/api/health" }
  }
}

resource "aws_lb_target_group" "tg" {
  for_each    = local.tgs
  name        = "lks-url-tg-${each.key}"
  port        = each.value.port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path                = each.value.path
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
  tags = { Name = "lks-url-tg-${each.key}" }
}

# Default rule -> frontend
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg["frontend"].arn
  }
}

# 1. /s/* -> api
resource "aws_lb_listener_rule" "short" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg["api"].arn
  }
  condition {
    path_pattern { values = ["/s/*"] }
  }
}

# 2. /api/stats/* -> analytics (HARUS sebelum /api/*)
resource "aws_lb_listener_rule" "stats" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg["analytics"].arn
  }
  condition {
    path_pattern { values = ["/api/stats/*"] }
  }
}

# 3. /api/* -> api
resource "aws_lb_listener_rule" "api" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 30
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg["api"].arn
  }
  condition {
    path_pattern { values = ["/api/*"] }
  }
}
