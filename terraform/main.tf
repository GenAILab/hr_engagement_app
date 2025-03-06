# Security Module
module "security" {
  source = "./modules/security"

  app_name    = var.app_name
  environment = var.environment
}

# Networking Module
module "networking" {
  source = "./modules/networking"

  app_name            = var.app_name
  environment         = var.environment
  vpc_cidr            = var.vpc_cidr
  container_port      = var.container_port
  allowed_ip_addresses = var.allowed_ip_addresses
  health_check_path   = var.health_check_path
}

# ECS Module
module "ecs" {
  source = "./modules/ecs"

  app_name                  = var.app_name
  environment               = var.environment
  aws_region                = var.aws_region
  container_image_tag       = var.container_tag
  container_port            = var.container_port
  container_cpu             = var.container_cpu
  container_memory          = var.container_memory
  desired_count             = var.desired_count
  ecs_tasks_sg_id           = module.networking.ecs_tasks_sg_id
  public_subnet_ids         = module.networking.public_subnet_ids
  target_group_arn          = module.networking.target_group_arn
  alb_listener_arn          = module.networking.alb_listener_arn
  ecs_task_execution_role_arn = module.security.ecs_task_execution_role_arn
  ecs_task_role_arn         = module.security.ecs_task_role_arn
  enable_auto_scaling       = var.enable_auto_scaling
  min_capacity              = var.min_capacity
  max_capacity              = var.max_capacity
  
  container_environment = [
    {
      name  = "ENVIRONMENT"
      value = var.environment
    },
    {
      name  = "APP_NAME"
      value = var.app_name
    },
    {
      name  = "S3_BUCKET"
      value = module.security.app_data_bucket_name
    }
  ]
}