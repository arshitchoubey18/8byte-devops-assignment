# 8byte DevOps Assignment

**Live Demo (Lab Environment):** http://arshit-8byte-alb-595835421.us-east-1.elb.amazonaws.com  
*Note: AWS Academy lab - auto-terminates after 4 hours. Screenshots attached in submission email.*

## Architecture Overview
- **Compute:** ECS Fargate (serverless containers)
- **Network:** VPC 10.0.0.0/16 with 2 public + 2 private subnets across us-east-1a/b
- **Database:** RDS PostgreSQL 15 in private subnets
- **Load Balancer:** Application Load Balancer
- **Registry:** ECR
- **IaC:** Terraform with S3 backend

## Part 1 - Infrastructure Provisioning ✅
- VPC, ECS Fargate, ALB, RDS PostgreSQL, ECR
- Security groups with least-privilege
- Terraform state in S3 with DynamoDB locking

```
cd terraform
terraform init
terraform apply -var="db_password=YourSecurePass123"
```
Part 2 - Deployment Automation ✅

GitHub Actions: .github/workflows/ci-cd.yml
```
PR → pytest tests
Merge → Build → Trivy scan → Push ECR → Deploy ECS
Staging: auto | Production: manual approval
Part 3 - Monitoring and Logging ✅
Dashboard: monitoring/cloudwatch-dashboard.json
Metrics: ECS CPU/Memory, ALB RequestCount/Latency, RDS Connections
Logs: CloudWatch Logs (/ecs/8byte-app)
```
Part 4 - Best Practices
```
Security:

RDS private only, SSM SecureString for secrets, SG isolation, IAM least-privilege, Trivy scanning

Cost Optimization:

Fargate (no idle EC2), db.t3.micro, 7-day backups, single NAT for dev

Secret Management: AWS SSM Parameter Store

Backup Strategy: RDS automated backups (7 days), S3 versioned Terraform state

```
Challenges Faced

See docs/CHALLENGES.md [blocked] for 5 real issues and resolutions
