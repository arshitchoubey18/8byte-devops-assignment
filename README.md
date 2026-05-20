# 8byte DevOps Assignment

**Live:** http://arshit-8byte-alb-595835421.us-east-1.elb.amazonaws.com

## Part 1 - Infrastructure ✅
- VPC (10.0.0.0/16) with public/private subnets across 2 AZs
- ECS Fargate, ALB, RDS PostgreSQL, ECR
- Terraform with S3 backend

## Part 2 - CI/CD ✅
GitHub Actions: PR tests → build → Trivy scan → ECR push → ECS deploy (staging auto, prod manual)

## Part 3 - Monitoring ✅
CloudWatch dashboard: `monitoring/cloudwatch-dashboard.json`

## Security
- RDS private, SSM SecureString, least-privilege IAM, SG isolation

## Challenges
See docs/CHALLENGES.md
