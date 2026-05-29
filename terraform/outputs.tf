# Lookup existing resources by name — avoids "undeclared resource" errors
data "aws_lb" "main" {
  name = "arshit-8byte-alb"
}

data "aws_lb_target_group" "tg" {
  name = "arshit-8byte-tg"
}

data "aws_ecs_cluster" "cluster" {
  cluster_name = "arshit-8byte-cluster"
}

data "aws_ecs_service" "service" {
  cluster_arn  = data.aws_ecs_cluster.cluster.arn
  service_name = "arshit-8byte-svc"
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = data.aws_lb.main.dns_name
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.app.repository_url
}

output "rds_endpoint" {
  description = "RDS endpoint address"
  value       = aws_db_instance.postgres.address
}

output "target_group_arn" {
  description = "ALB Target Group ARN"
  value       = data.aws_lb_target_group.tg.arn
}

output "cluster_name" {
  description = "ECS cluster name"
  value       = data.aws_ecs_cluster.cluster.cluster_name
}

output "service_name" {
  description = "ECS service name"
  value       = data.aws_ecs_service.service.service_name
}
