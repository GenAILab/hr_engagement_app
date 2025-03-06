output "ecs_task_execution_role_arn" {
  description = "The ARN of the ECS task execution role"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "ecs_task_role_arn" {
  description = "The ARN of the ECS task role"
  value       = aws_iam_role.ecs_task_role.arn
}

output "app_data_bucket_name" {
  description = "The name of the S3 bucket for application data"
  value       = aws_s3_bucket.app_data.bucket
}

output "app_data_bucket_arn" {
  description = "The ARN of the S3 bucket for application data"
  value       = aws_s3_bucket.app_data.arn
}

output "github_actions_user_name" {
  description = "The name of the IAM user for GitHub Actions"
  value       = aws_iam_user.github_actions.name
}

output "github_actions_access_key_id" {
  description = "The access key ID for the GitHub Actions IAM user"
  value       = aws_iam_access_key.github_actions.id
}

output "github_actions_secret_access_key" {
  description = "The secret access key for the GitHub Actions IAM user"
  value       = aws_iam_access_key.github_actions.secret
  sensitive   = true
}