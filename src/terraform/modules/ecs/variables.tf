variable "cluster_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "nodered_ecr_url" {
  description = "ECR repository URL for Node-RED"
  type        = string
}

variable "mqtt_ecr_url" {
  description = "ECR repository URL for MQTT broker"
  type        = string
}

variable "nodejs_app_ecr_url" {
  description = "ECR repository URL for Node.js app"
  type        = string
}