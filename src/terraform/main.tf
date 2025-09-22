module "vpc" {
  source              = "./modules/vpc"
  vpc_cidr            = var.vpc_cidr
  public_subnet1_cidr = var.public_subnet1_cidr
  public_subnet2_cidr = var.public_subnet2_cidr
  az1                 = var.az1
  az2                 = var.az2
}

# module "weight_sensor_ecr" {
#   source          = "./modules/ecr"
#   repository_name = var.weight_sensor_repo_name
# }

# module "mqtt_ecr" {
#   source          = "./modules/ecr"
#   repository_name = var.mqtt_repo_name
# }

module "nodejs_ecr" {
  source          = "./modules/ecr"
  repository_name = var.nodejs_app_repo_name
}

module "alb" {
  source  = "./modules/alb"
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets
}

module "ecs" {
  source       = "./modules/ecs"
  cluster_name = var.cluster_name
  vpc_id       = module.vpc.vpc_id
  subnets      = module.vpc.public_subnets
  nodejs_app_ecr_url = module.nodejs_ecr.repository_url
  alb_sg_id          = module.alb.alb_sg_id
  nodered_tg_arn     = module.alb.nodered_tg_arn
  nodejs_app_tg_arn  = module.alb.nodejs_app_tg_arn
}

module "codepipeline" {
  source               = "./modules/codepipeline"
  project_name         = var.project_name
  github_owner         = var.github_owner
  github_repo          = var.github_repo
  github_branch        = var.github_branch
  github_token         = var.github_token
  nodejs_ecr_repository       = module.nodejs_ecr.repository_url
  dockerhub_username   = var.dockerhub_username
  dockerhub_password   = var.dockerhub_password
  aws_region           = var.aws_region
  buildspec_path       = var.buildspec_path
}
