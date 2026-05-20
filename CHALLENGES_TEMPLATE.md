# Challenges Faced

1. NAT Gateway cost - used single NAT for both private subnets
2. ECS task cannot reach RDS - fixed by security group ingress
3. GitHub Actions OIDC vs keys - used keys for simplicity