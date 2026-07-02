# GR-PLAN-005: VPC with no flow log — deny at plan and apply
# getresources("aws_flow_log", {vpc_id = attrs.id}): no flow logs exist → empty list → deny
# Plan: empty list is deterministic (type missing entirely) → FAIL
# Apply: same → FAIL

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
  tags = { Name = "gr-plan-005-vpc-no-flowlog" }
}

# Intentionally no aws_flow_log resource
