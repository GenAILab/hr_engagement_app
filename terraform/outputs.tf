output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = module.networking.alb_dns_name
}

output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = module.ecs.ecr_repository_url
}

output "app_data_bucket_name" {
  description = "The name of the S3 bucket for application data"
  value       = module.security.app_data_bucket_name
}

output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group"
  value       = module.ecs.cloudwatch_log_group_name
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "The name of the ECS service"
  value       = module.ecs.service_name
}

output "github_actions_user_name" {
  description = "The name of the IAM user for GitHub Actions"
  value       = module.security.github_actions_user_name
}

output "github_actions_access_key_id" {
  description = "The access key ID for the GitHub Actions IAM user"
  value       = module.security.github_actions_access_key_id
}

output "github_actions_secret_access_key" {
  description = "The secret access key for the GitHub Actions IAM user"
  value       = module.security.github_actions_secret_access_key
  sensitive   = true
}