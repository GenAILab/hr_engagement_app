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
    key     = "terraform/environments/dev/state"
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
  environment               = "dev"
  desired_count             = 1
  container_cpu             = 256
  container_memory          = 512
  enable_auto_scaling       = false
}