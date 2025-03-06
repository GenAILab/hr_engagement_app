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

variable "allowed_ip_addresses" {
  description = "List of IP addresses allowed to access the application"
  type        = list(string)
  default     = [
    "195.160.234.0/24",    # EU-GW
    "195.160.232.0/24",    # UA-GW
    "195.160.233.0/24",    # US-GW
    "149.7.27.0/24",       # EU-GW-Cogent-ISP
    "12.110.213.199/32",   # US-ATnT-GW
    "216.201.202.199/32"   # US-Logix-GW
  ]
} 