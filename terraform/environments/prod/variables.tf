variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "The deployment environment"
  type        = string
  default     = "prod"
}

variable "container_tag" {
  description = "The tag of the container image to deploy"
  type        = string
  default     = "latest"
}