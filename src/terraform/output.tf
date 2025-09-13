output "alb_dns_name" {
  value = module.alb.alb_dns
}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}

# ECR outputs
output "weight_sensor_ecr_url" {
  value = module.weight_sensor_ecr.repository_url
}

output "mqtt_ecr_url" {
  value = module.mqtt_ecr.repository_url
}

output "nodejs_app_ecr_url" {
  value = module.nodejs_ecr.repository_url
}

# VPC outputs
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}