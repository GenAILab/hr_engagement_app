terraform {
  required_version = ">= 1.0.0, < 2.0.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  
  # Note: Backend configuration is defined in each environment directory
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