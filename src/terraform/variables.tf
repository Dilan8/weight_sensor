# ==============================
# VPC Variables
# ==============================
variable "vpc_cidr" { 
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet1_cidr" { 
  type    = string
  default = "10.0.1.0/24"
}

variable "public_subnet2_cidr" { 
  type    = string
  default = "10.0.2.0/24"
}

variable "az1" { 
  type    = string
  default = "ap-southeast-2a"
}

variable "az2" { 
  type    = string
  default = "ap-southeast-2b"
}

# ==============================
# ECS / Cluster Variables
# ==============================
variable "cluster_name" { 
  type    = string
  default = "ecs-cluster"
}

# ==============================
# ECR Variables
# ==============================
variable "weight_sensor_repo_name" { 
  type    = string
  default = "weight-sensor"
}

variable "mqtt_repo_name" { 
  type    = string
  default = "mqtt-broker"
}

variable "nodejs_app_repo_name" { 
  type    = string
  default = "nodejs-app"
}

# ==============================
# CodePipeline Variables
# ==============================
variable "project_name" { 
  type    = string
  default = "react-app"
}

variable "github_owner" { 
  type = string
}

variable "github_repo" { 
  type = string
}

variable "github_branch" { 
  type    = string
  default = "main"
}

variable "github_token" { 
  type      = string
  sensitive = true
}

variable "dockerhub_username" { 
  type = string
}

variable "dockerhub_password" { 
  type      = string
  sensitive = true
}

variable "aws_region" { 
  type    = string
  default = "ap-southeast-2"
}

variable "buildspec_path" { 
  type    = string
  default = "buildspec.yml"
}
