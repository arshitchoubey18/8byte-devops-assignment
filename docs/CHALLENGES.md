# Challenges Faced

1. **RDS Version** - 15.4 not available → removed version pin
2. **Password** - '@' rejected → used Alphanumeric
3. **IAM SSM** - ECS couldn't read SSM → added inline policy ssm:GetParameters + kms:Decrypt
4. **Deployment** - needed force-new-deployment after ECR push

5. **CI/CD IAM Limitation** - Lab account blocks `iam:AttachUserPolicy`. Workaround: In production use OIDC role assumption instead of long-lived keys. Pipeline design validated, execution blocked by lab policy.

