# VPC Module
module "vpc" {
  source    = "./modules/vpc"
  vpc_cidr  = var.vpc_cidr
}

# ECS Module
module "ecs" {
  source       = "./modules/ecs"
  cluster_name = var.cluster_name
  vpc_id       = module.vpc.vpc_id
  subnets      = module.vpc.public_subnets
  nodered_ecr_url    = module.weight_sensor_ecr.repository_url
  mqtt_ecr_url       = module.mqtt_ecr.repository_url
  nodejs_app_ecr_url = module.nodejs_ecr.repository_url
}

# ALB Module
module "alb" {
  source  = "./modules/alb"
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets
  ecs_sg  = module.ecs.ecs_sg_id
}

# ECR Modules
module "weight_sensor_ecr" {
  source          = "./modules/ecr"
  repository_name = var.weight_sensor_repo_name
}

module "mqtt_ecr" {
  source          = "./modules/ecr"
  repository_name = var.mqtt_repo_name
}

module "nodejs_ecr" {
  source          = "./modules/ecr"
  repository_name = var.nodejs_app_repo_name
}
