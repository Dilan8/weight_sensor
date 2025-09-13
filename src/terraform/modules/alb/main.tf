resource "aws_lb" "main" {
  name               = "ecs-alb"
  load_balancer_type = "application"
  subnets            = var.subnets
  security_groups    = [var.ecs_sg]
}

resource "aws_lb_target_group" "nodered_tg" {
  name     = "nodered-tg"
  port     = 1880
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nodered_tg.arn
  }
}
