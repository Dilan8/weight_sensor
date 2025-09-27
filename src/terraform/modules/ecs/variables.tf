variable "cluster_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "alb_sg_id" {
  type = string
}

variable "nodered_tg_arn" {
  type = string
}


variable "mqtt_tg_arn" {
  type = string
}

variable "nodejs_app_tg_arn" {
  type = string
}

# variable "nodered_ecr_url" {
#   type = string
# }

# variable "mqtt_ecr_url" {
#   type = string
# }

variable "nodejs_app_ecr_url" {
  type = string
}
