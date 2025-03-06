variable "app_name" {
  description = "The name of the application"
  type        = string
}

variable "environment" {
  description = "The deployment environment (dev, staging, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "container_port" {
  description = "The port the container listens on"
  type        = number
}

variable "allowed_ip_addresses" {
  description = "List of IP addresses allowed to access the application"
  type        = list(string)
}

variable "health_check_path" {
  description = "The path to check for application health"
  type        = string
  default     = "/"
}