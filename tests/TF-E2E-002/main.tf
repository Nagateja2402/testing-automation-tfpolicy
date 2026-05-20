# TF-E2E-002: Full lifecycle — create blocked by mandatory policy
# VPC has no Environment tag; policy should deny at plan and apply.
# tfp plan: FAIL
# tfp apply: FAIL (blocked by policy, apply should not proceed)

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "tf-e2e-002-vpc"
    # No Environment tag intentionally
  }
}
