# TF-E2E-001: Full lifecycle — create with policy pass
# tfp plan: PASS (tags are config-known, condition resolves)
# tfp apply: PASS

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
    Name        = "tf-e2e-001-vpc"
    Environment = "dev"
  }
}
