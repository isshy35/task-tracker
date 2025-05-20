provider "aws" {
  region = var.aws_region
}

# VPC and network resources
module "vpc" {
  source = "./modules/vpc"
  
  environment = var.environment
  vpc_cidr    = var.vpc_cidr
  az_count    = var.az_count
}

# ECR repositories
module "ecr" {
  source = "./modules/ecr"
  
  environment = var.environment
}

# ECS cluster and related resources
module "ecs" {
  source = "./modules/ecs"
  
  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  private_subnets     = module.vpc.private_subnets
  public_subnets      = module.vpc.public_subnets
  frontend_image      = "${module.ecr.frontend_repository_url}:latest"
  backend_image       = "${module.ecr.backend_repository_url}:latest"
  database_username   = var.database_username
  database_password   = var.database_password
  database_name       = var.database_name
}

# S3 and CloudFront for static frontend hosting
module "frontend_hosting" {
  source = "./modules/frontend-hosting"
  
  environment = var.environment
  domain_name = var.domain_name
}

# Route53 records
module "dns" {
  source = "./modules/dns"
  
  domain_name         = var.domain_name
  environment         = var.environment
  cloudfront_domain   = module.frontend_hosting.cloudfront_domain_name
  alb_domain_name     = module.ecs.alb_domain_name
}
