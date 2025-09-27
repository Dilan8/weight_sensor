# ==============================
# ECS Cluster
# ==============================
resource "aws_ecs_cluster" "main" {
  name = var.cluster_name
}

# ==============================
# Security Group for ECS Tasks
# ==============================
resource "aws_security_group" "ecs_sg" {
  name   = "ecs-sg-one"
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 1880
    to_port         = 1880
    protocol        = "tcp"
    security_groups = [var.alb_sg_id] # ALB for Node-RED
  }

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [var.alb_sg_id] # ALB for Node.js
  }

  ingress {
    from_port   = 1883
    to_port     = 1883
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow MQTT (via NLB)
  }
}

# ==============================
# IAM Role for ECS Task Execution
# ==============================
resource "aws_iam_role" "ecs_task_execution" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ==============================
# EFS for Mosquitto Config
# ==============================
resource "aws_efs_file_system" "mosquitto" {
  creation_token = "mosquitto-config"
}

resource "aws_efs_mount_target" "mosquitto" {
  for_each = toset(var.subnets)

  file_system_id  = aws_efs_file_system.mosquitto.id
  subnet_id       = each.value
  security_groups = [aws_security_group.ecs_sg.id]
}

# ==============================
# ECS Task Definitions (Fargate)
# ==============================
resource "aws_ecs_task_definition" "nodered" {
  family                   = "nodered-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([{
    name      = "nodered"
    image     = "nodered/node-red:latest"
    cpu       = 256
    memory    = 512
    essential = true
    portMappings = [{
      containerPort = 1880
      protocol      = "tcp"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/nodered-test"
        "awslogs-region"        = "ap-southeast-2"
        "awslogs-stream-prefix" = "nodered"
      }
    }
  }])
}

resource "aws_ecs_task_definition" "mqtt" {
  family                   = "mqtt-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([{
    name      = "mqtt"
    image     = "eclipse-mosquitto:2.0.22"
    cpu       = 256
    memory    = 512
    essential = true
    portMappings = [{
      containerPort = 1883
      protocol      = "tcp"
    }]
    
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/mosquitto-test"
        "awslogs-region"        = "ap-southeast-2"
        "awslogs-stream-prefix" = "mqtt"
      }
    }
  }])
}

resource "aws_ecs_task_definition" "nodejs_app" {
  family                   = "nodejs-app-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([{
    name      = "nodejs-app"
    image     = var.nodejs_app_ecr_url
    cpu       = 256
    memory    = 512
    essential = true
    portMappings = [{
      containerPort = 3000
      protocol      = "tcp"
    }]
    environment = [
      {
        name  = "MQTT_BROKER"
        value = "tcp://mqtt-nlb-one-6bf69bc797ab88fb.elb.ap-southeast-2.amazonaws.com:1883"
      },
      {
        name  = "MONGO_URI"
        value = "mongodb://docdb_user:DocdbPass123!@sensor-docdb-cluster.cluster-czueamasy3z1.ap-southeast-2.docdb.amazonaws.com:27017/supermarket?tls=true&tlsCAFile=/usr/src/app/global-bundle.pem&replicaSet=rs0&readPreference=secondaryPreferred&retryWrites=false&authMechanism=SCRAM-SHA-1"
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/nodejs-app-test"
        "awslogs-region"        = "ap-southeast-2"
        "awslogs-stream-prefix" = "nodejs-app"
      }
    }
  }])
}

# ==============================
# ECS Services (Fargate)
# ==============================
resource "aws_ecs_service" "nodered" {
  name            = "nodered-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.nodered.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnets
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.nodered_tg_arn
    container_name   = "nodered"
    container_port   = 1880
  }
}

resource "aws_ecs_service" "mqtt" {
  name            = "mqtt-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.mqtt.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnets
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.mqtt_tg_arn
    container_name   = "mqtt"
    container_port   = 1883
  }
}

resource "aws_ecs_service" "nodejs_app" {
  name            = "nodejs-app-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.nodejs_app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnets
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.nodejs_app_tg_arn
    container_name   = "nodejs-app"
    container_port   = 3000
  }
}
