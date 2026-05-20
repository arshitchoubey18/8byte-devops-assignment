# 8Byte.ai DevOps Assignment

End-to-end DevOps setup on AWS using Terraform, ECS Fargate, RDS Postgres, and GitHub Actions.

## Architecture
- VPC with 2 public + 2 private subnets across ap-south-1a/b
- Application Load Balancer -> ECS Fargate (Flask app)
- RDS PostgreSQL in private subnets
- ECR for Docker images
- CloudWatch Logs + Metrics
- Secrets in SSM Parameter Store

## Setup
1. Create S3 bucket for Terraform state
2. `cd terraform`
3. `terraform init -backend-config="bucket=YOUR_BUCKET" -backend-config="key=devops/terraform.tfstate" -backend-config="region=ap-south-1"`
4. `terraform apply -var="db_password=StrongPass123!"`

## CI/CD
- PR: runs tests + Trivy fs scan
- Push to main: builds Docker, pushes to ECR, scans image, deploys to staging
- Production: manual approval in GitHub Environments

## Security
- RDS not public, only ECS SG allowed
- Secrets via SSM SecureString, not in code
- IAM least privilege for task execution
- ECR image scanning enabled

## Cost Optimization
- t3.micro RDS, Fargate 0.25vCPU, single NAT, 7-day log retention