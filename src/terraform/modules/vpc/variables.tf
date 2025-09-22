variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnet1_cidr" {
  type        = string
  description = "CIDR block for the first public subnet"
}

variable "public_subnet2_cidr" {
  type        = string
  description = "CIDR block for the second public subnet"
}

variable "az1" {
  type        = string
  description = "Availability zone for the first public subnet"
}

variable "az2" {
  type        = string
  description = "Availability zone for the second public subnet"
}
