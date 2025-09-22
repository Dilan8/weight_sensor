
# ECR outputs

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

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "codepipeline_name" {
  value = module.codepipeline.pipeline_name
}

