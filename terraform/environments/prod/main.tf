terraform {
  required_version = ">= 1.0.0, < 2.0.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket  = "app-builder-dplmt-tf-state"
    key     = "terraform/environments/prod/state"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "HR Engagement App"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

module "hr_engagement_app" {
  source = "../../"

  # Override default variables
  environment               = "prod"
  container_tag             = var.container_tag
  desired_count             = 2
  container_cpu             = 512
  container_memory          = 1024
  enable_auto_scaling       = true
  min_capacity              = 2
  max_capacity              = 10
}