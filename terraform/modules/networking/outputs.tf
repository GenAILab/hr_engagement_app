output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "alb_sg_id" {
  description = "The ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "ecs_tasks_sg_id" {
  description = "The ID of the ECS tasks security group"
  value       = aws_security_group.ecs_tasks.id
}

output "alb_id" {
  description = "The ID of the ALB"
  value       = aws_lb.main.id
}

output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.main.dns_name
}

output "target_group_arn" {
  description = "The ARN of the target group"
  value       = aws_lb_target_group.app.arn
}

output "alb_listener_arn" {
  description = "The ARN of the ALB listener"
  value       = aws_lb_listener.http.arn
}