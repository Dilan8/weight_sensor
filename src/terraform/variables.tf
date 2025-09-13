variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-southeast-2"   # Sydney region
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "cluster_name" {
  description = "ECS Cluster Name"
  type        = string
  default     = "ecs-cluster"
}

variable "weight_sensor_repo_name" {
  description = "rep name"
  type = string
  default = "weight-sensor-repo"
}

variable "mqtt_repo_name" {
  description = "rep name"
  type = string
  default = "mqtt-sensor-repo"
}

variable "nodejs_app_repo_name" {
  description = "rep name"
  type = string
  default = "nodejs-sensor-repo"
}