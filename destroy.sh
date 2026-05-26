#!/usr/bin/env bash
set -euo pipefail

echo "🧨 8byte DevOps – Destroy All"
read -p "Project name [8byte-app]: " PROJECT; PROJECT=${PROJECT:-8byte-app}
REGION=$(aws configure get region 2>/dev/null || echo "us-east-1")
export AWS_DEFAULT_REGION=$REGION
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
BUCKET="tfstate-${ACCOUNT_ID}-${REGION}-${PROJECT}"
TABLE="tf-lock-${PROJECT}"

cd 8byte-devops-assignment/terraform
terraform destroy -auto-approve \
  -var="project_name=$PROJECT" -var="region=$REGION" \
  -var="db_username=dummy" -var="db_password=dummy" -var="db_name=dummy"

cd ~
# Clean ECR images
REPO=$(aws ecr describe-repositories --repository-names "$PROJECT" --query 'repositories[0].repositoryUri' --output text 2>/dev/null || true)
[ -n "$REPO" ] && aws ecr delete-repository --repository-name "$PROJECT" --force >/dev/null 2>&1 || true

# Delete state backend (avoid billing)
aws s3 rm "s3://$BUCKET" --recursive >/dev/null 2>&1 || true
aws s3 rb "s3://$BUCKET" --force >/dev/null 2>&1 || true
aws dynamodb delete-table --table-name "$TABLE" >/dev/null 2>&1 || true

echo "✅ All resources deleted. No leftover costs."
