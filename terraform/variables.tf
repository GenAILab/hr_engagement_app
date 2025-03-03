variable "aws_region" {
  description = "The AWS region to deploy resources in"
  default     = "us-east-1"
}

variable "deploy_user_name" {
  description = "The name of the IAM user for deployment"
  default     = "deploy-user-github"
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket for application deployment"
  default     = "app-builder-deployment"
}

variable "app_name" {
  description = "The name of the Elastic Beanstalk application"
  default     = "hr-engagement-app"
} 