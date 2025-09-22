# ==============================
# Security Group for ALB
# ==============================
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "ALB security group"
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
}

# ==============================
# Application Load Balancer
# ==============================
resource "aws_lb" "main" {
  name               = "ecs-alb"
  load_balancer_type = "application"
  subnets            = var.subnets
  security_groups    = [aws_security_group.alb_sg.id]
}

# ==============================
# Target Groups (IP target type for Fargate)
# ==============================
resource "aws_lb_target_group" "nodered_tg" {
  name        = "nodered-tg"
  port        = 1880
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
}

resource "aws_lb_target_group" "nodejs_app_tg" {
  name        = "nodejs-app-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
}

# ==============================
# ALB Listener
# ==============================
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.main.arn
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
# Listener Rules
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
      values = ["/nodered*"]
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
      values = ["/app*"]
    }
  }
}

