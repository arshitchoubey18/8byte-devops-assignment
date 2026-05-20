terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    # configure via: terraform init -backend-config=backend.hcl
    # bucket = "8byte-terraform-state"
    # key    = "devops-assignment/terraform.tfstate"
    # region = "ap-south-1"
    # dynamodb_table = "terraform-locks"
  }
}

provider "aws" {
  region = var.aws_region
}