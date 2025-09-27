variable "vpc_id" {
  description = "VPC ID for DocumentDB"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for DocumentDB"
  type        = list(string)
}

variable "cluster_name" {
  description = "DocumentDB cluster name"
  type        = string
}

variable "username" {
  description = "DocumentDB master username"
  type        = string
}

variable "password" {
  description = "DocumentDB master password"
  type        = string
  sensitive   = true
}

variable "instance_count" {
  description = "Number of DocumentDB instances"
  type        = number
  default     = 1
}

variable "instance_class" {
  description = "Instance class for DocumentDB instances"
  type        = string
  default     = "db.r5.large"
}

variable "ecs_sg_ids" {
  description = "List of ECS security groups allowed to connect to DocumentDB"
  type        = list(string)
}
