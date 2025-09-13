variable "vpc_id" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "ecs_sg" {
  type = string
}
