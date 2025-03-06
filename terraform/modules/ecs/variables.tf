variable "app_name" {
  description = "The name of the application"
  type        = string
}

variable "environment" {
  description = "The deployment environment (dev, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
}

variable "container_image_tag" {
  description = "The tag for the container image"
  type        = string
  default     = "latest"
}

variable "container_port" {
  description = "The port the container listens on"
  type        = number
}

variable "container_cpu" {
  description = "CPU units for the container (1024 = 1 vCPU)"
  type        = number
}

variable "container_memory" {
  description = "Memory for the container in MiB"
  type        = number
}

variable "container_environment" {
  description = "Environment variables for the container"
  type        = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "desired_count" {
  description = "The desired number of container instances"
  type        = number
}

variable "ecs_tasks_sg_id" {
  description = "The ID of the ECS tasks security group"
  type        = string
}

variable "public_subnet_ids" {
  description = "The IDs of the public subnets"
  type        = list(string)
}

variable "target_group_arn" {
  description = "The ARN of the target group"
  type        = string
}

variable "alb_listener_arn" {
  description = "The ARN of the ALB listener"
  type        = string
}

variable "ecs_task_execution_role_arn" {
  description = "The ARN of the ECS task execution role"
  type        = string
}

variable "ecs_task_role_arn" {
  description = "The ARN of the ECS task role"
  type        = string
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