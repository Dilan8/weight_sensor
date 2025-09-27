output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "nodered_tg_arn" {
  value = aws_lb_target_group.nodered_tg.arn
}

output "nodejs_app_tg_arn" {
  value = aws_lb_target_group.nodejs_app_tg.arn
}

output "mqtt_tg_arn" {
  value = aws_lb_target_group.mqtt_tg.arn   # <-- new output
}

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

output "alb_arn" {
  value = aws_lb.alb.arn
}

output "mqtt_nlb_dns" {
  value = aws_lb.nlb.dns_name
}