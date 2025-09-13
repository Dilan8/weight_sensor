resource "aws_ecs_cluster" "main" {
  name = var.cluster_name
}

data "aws_ami" "ecs_ami" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}

resource "aws_security_group" "ecs_sg" {
  vpc_id = var.vpc_id

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Example inbound rules
  ingress {
    from_port   = 1880       # Node-RED UI
    to_port     = 1880
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # or restrict to your IP for security
  }

  ingress {
    from_port   = 1883       # MQTT broker
    to_port     = 1883
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # same note about restriction
  }

  ingress {
    from_port   = 3000       # Node.js app
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_launch_template" "ecs_lt" {
  name_prefix   = "ecs-instance"
  image_id      = data.aws_ami.ecs_ami.id
  instance_type = "t3.micro"

  user_data = base64encode(<<EOF
#!/bin/bash
echo ECS_CLUSTER=${aws_ecs_cluster.main.name} >> /etc/ecs/ecs.config
EOF
  )

  network_interfaces {
    security_groups = [aws_security_group.ecs_sg.id]
  }
}

resource "aws_autoscaling_group" "ecs_asg" {
  desired_capacity    = 1
  max_size            = 3
  min_size            = 1
  vpc_zone_identifier = var.subnets

  launch_template {
    id      = aws_launch_template.ecs_lt.id
    version = "$Latest"
  }

    tag {
        key                 = "Name"
        value               = "ECS-Node"
        propagate_at_launch = true
    }
}

# Node-RED Task
resource "aws_ecs_task_definition" "nodered" {
  family                   = "nodered-task"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"

container_definitions = jsonencode([{
  name      = "nodered"
  image     = var.nodered_ecr_url
  cpu       = 256
  memory    = 512
  essential = true
  portMappings = [{
    containerPort = 1880
    hostPort      = 1880
  }]
}])
}

# MQTT Task
resource "aws_ecs_task_definition" "mqtt" {
  family                   = "mqtt-task"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"

container_definitions = jsonencode([{
  name      = "mqtt"
  image     = var.mqtt_ecr_url
  cpu       = 256
  memory    = 512
  essential = true
  portMappings = [{
    containerPort = 1883
    hostPort      = 1883
  }]
}])

}

# Node.js App Task
resource "aws_ecs_task_definition" "nodejs_app" {
  family                   = "nodejs-app-task"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"

container_definitions = jsonencode([{
  name      = "nodejs-app"
  image     = var.nodejs_app_ecr_url
  cpu       = 256
  memory    = 512
  essential = true
  portMappings = [{
    containerPort = 3000
    hostPort      = 3000
  }]
}])
}

# Node-RED Service
resource "aws_ecs_service" "nodered" {
  name            = "nodered-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.nodered.arn
  desired_count   = 1
  launch_type     = "EC2"

  load_balancer {
    target_group_arn = aws_lb_target_group.nodered_tg.arn
    container_name   = "nodered"
    container_port   = 1880
  }

}

# MQTT Service
resource "aws_ecs_service" "mqtt" {
  name            = "mqtt-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.mqtt.arn
  desired_count   = 1
  launch_type     = "EC2"
}

# Node.js App Service
resource "aws_ecs_service" "nodejs_app" {
  name            = "nodejs-app-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.nodejs_app.arn
  desired_count   = 1
  launch_type     = "EC2"

  load_balancer {
    target_group_arn = aws_lb_target_group.nodejs_app_tg.arn
    container_name   = "nodejs-app"
    container_port   = 3000
  }
}

resource "aws_lb_target_group" "nodered_tg" {
  name     = "nodered-tg"
  port     = 1880
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_target_group" "nodejs_app_tg" {
  name     = "nodejs-app-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}
