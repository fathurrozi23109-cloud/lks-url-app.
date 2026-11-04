output "alb_dns_name" { value = aws_lb.alb.dns_name }
output "target_group_arns" { value = { for k, t in aws_lb_target_group.tg : k => t.arn } }
