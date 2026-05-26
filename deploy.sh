#!/usr/bin/env bash
set -euo pipefail

echo "🚀 8byte DevOps – CloudShell Deploy"

# --- 1. Inputs (secure prompts) ---
REGION=$(aws configure get region 2>/dev/null || echo "us-east-1")
read -p "AWS Region [$REGION]: " R; REGION=${R:-$REGION}
read -p "Project name [8byte-app]: " PROJECT; PROJECT=${PROJECT:-8byte-app}
read -p "DB username [appuser]: " DB_USER; DB_USER=${DB_USER:-appuser}
read -s -p "DB password (12+ chars): " DB_PASS; echo
read -p "DB name [appdb]: " DB_NAME; DB_NAME=${DB_NAME:-appdb}
read -p "Container port [8000]: " PORT; PORT=${PORT:-8000}

export AWS_DEFAULT_REGION=$REGION
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# --- 2. Install Terraform in CloudShell (no sudo needed) ---
if! command -v terraform >/dev/null; then
  echo "Installing Terraform..."
  mkdir -p ~/bin
  curl -sL https://releases.hashicorp.com/terraform/1.9.5/terraform_1.9.5_linux_amd64.zip -o /tmp/tf.zip
  unzip -q -o /tmp/tf.zip -d ~/bin
  export PATH=~/bin:$PATH
fi

# --- 3. Create backend bucket + lock table ---
BUCKET="tfstate-${ACCOUNT_ID}-${REGION}-${PROJECT}"
TABLE="tf-lock-${PROJECT}"
aws s3api head-bucket --bucket "$BUCKET" 2>/dev/null || aws s3 mb "s3://$BUCKET" --region "$REGION"
aws s3api put-bucket-versioning --bucket "$BUCKET" --versioning-configuration Status=Enabled
aws dynamodb describe-table --table-name "$TABLE" >/dev/null 2>&1 || \
aws dynamodb create-table --table-name "$TABLE" --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH --billing-mode PAY_PER_REQUEST >/dev/null

# --- 4. Clone repo ---
[ -d 8byte-devops-assignment ] || git clone https://github.com/arshitchoubey18/8byte-devops-assignment.git
cd 8byte-devops-assignment/terraform

# --- 5. Inject backend ---
cat > backend.tf <<EOF
terraform {
  backend "s3" {
    bucket = "$BUCKET"
    key = "$PROJECT/terraform.tfstate"
    region = "$REGION"
    dynamodb_table = "$TABLE"
    encrypt = true
  }
}
EOF

# --- 6. Terraform apply ---
terraform init -upgrade
terraform apply -auto-approve \
  -var="project_name=$PROJECT" \
  -var="region=$REGION" \
  -var="db_username=$DB_USER" \
  -var="db_password=$DB_PASS" \
  -var="db_name=$DB_NAME" \
  -var="container_port=$PORT"

ECR_URL=$(terraform output -raw ecr_repository_url)
ALB_DNS=$(terraform output -raw alb_dns_name)
CLUSTER=$(terraform output -raw ecs_cluster_name)
SERVICE=$(terraform output -raw ecs_service_name)

cd..

# --- 7. Build & push image (Docker in CloudShell) ---
echo "Building container in CloudShell..."
aws ecr get-login-password | docker login --username AWS --password-stdin "$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"
docker build -t "$ECR_URL:latest".
docker push "$ECR_URL:latest"

# --- 8. Deploy to ECS ---
aws ecs update-service --cluster "$CLUSTER" --service "$SERVICE" --force-new-deployment >/dev/null
aws ecs wait services-stable --cluster "$CLUSTER" --services "$SERVICE"

echo ""
echo "✅ DEPLOYED"
echo "Live URL: http://$ALB_DNS"
echo "ECR: $ECR_URL"
echo "Logs: /ecs/$PROJECT in CloudWatch"
