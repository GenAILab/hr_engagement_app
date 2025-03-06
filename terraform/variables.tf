variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "The deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "app_name" {
  description = "The name of the application"
  type        = string
  default     = "hr-engagement-app"
}

variable "container_tag" {
  description = "The tag for the container image"
  type        = string
  default     = "latest"
}

variable "container_port" {
  description = "The port the container listens on"
  type        = number
  default     = 80
}

variable "container_cpu" {
  description = "CPU units for the container (1024 = 1 vCPU)"
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Memory for the container in MiB"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "The desired number of container instances"
  type        = number
  default     = 2
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "allowed_ip_addresses" {
  description = "List of IP addresses allowed to access the application"
  type        = list(string)
  default     = [
    "195.160.234.0/24",    # EU-GW
    "195.160.232.0/24",    # UA-GW
    "195.160.233.0/24"     # US-GW
  ]
}

variable "health_check_path" {
  description = "The path to check for application health"
  type        = string
  default     = "/"
}

variable "enable_auto_scaling" {
  description = "Whether to enable auto scaling for the ECS service"
  type        = bool
  default     = true
}

variable "min_capacity" {
  description = "Minimum number of container instances"
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Maximum number of container instances"
  type        = number
  default     = 10
}