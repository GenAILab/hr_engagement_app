output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = module.hr_engagement_app.alb_dns_name
}

output "app_data_bucket_name" {
  description = "The name of the S3 bucket for application data"
  value       = module.hr_engagement_app.app_data_bucket_name
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = module.hr_engagement_app.ecs_cluster_name
}

output "ecs_service_name" {
  description = "The name of the ECS service"
  value       = module.hr_engagement_app.ecs_service_name
}

output "github_actions_user_name" {
  description = "The name of the IAM user for GitHub Actions"
  value       = module.hr_engagement_app.github_actions_user_name
}