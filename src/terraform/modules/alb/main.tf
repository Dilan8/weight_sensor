# ==============================
# Security Group for ALB
# ==============================
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg-one"
  description = "Allow HTTP traffic to ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # open to internet
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ==============================
# Application Load Balancer (ALB)
# ==============================
resource "aws_lb" "alb" {
  name               = "ecs-alb-one"
  load_balancer_type = "application"
  subnets            = var.subnets
  security_groups    = [aws_security_group.alb_sg.id]
}

# ==============================
# Network Load Balancer (NLB) for MQTT
# ==============================
resource "aws_lb" "nlb" {
  name               = "mqtt-nlb-one"
  load_balancer_type = "network"
  subnets            = var.subnets
}

# ==============================
# Target Groups
# ==============================
resource "aws_lb_target_group" "nodered_tg" {
  name        = "nodered-tg-one"
  port        = 1880
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
}

resource "aws_lb_target_group" "nodejs_app_tg" {
  name        = "nodejs-app-tg-one"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

    health_check {
    protocol            = "HTTP"
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_target_group" "mqtt_tg" {
  name        = "mqtt-tg-one"
  port        = 1883
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    protocol            = "TCP"
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 10
    interval            = 30
  }
}

# ==============================
# ALB Listener (HTTP)
# ==============================
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

# ==============================
# ALB Listener Rules
# ==============================
resource "aws_lb_listener_rule" "nodered_rule" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nodered_tg.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

resource "aws_lb_listener_rule" "nodejs_rule" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nodejs_app_tg.arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}

# ==============================
# NLB Listener (TCP for MQTT)
# ==============================
resource "aws_lb_listener" "mqtt_listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 1883
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mqtt_tg.arn
  }
}
