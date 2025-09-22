output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "alb_dns_name" {
  value = aws_lb.main.dns_name
}

output "nodered_tg_arn" {
  value = aws_lb_target_group.nodered_tg.arn
}

output "nodejs_app_tg_arn" {
  value = aws_lb_target_group.nodejs_app_tg.arn
}
