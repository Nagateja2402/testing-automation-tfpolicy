# OP-INF-004: meta.operation="create" overrides inference from attrs+prior_attrs.
# In L2/L3, new bucket is always "create" → create policy runs → env tag present → PASS.
# tfp plan: PASS
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

resource "aws_s3_bucket" "main" {
  bucket = "op-inf-004-bucket"
  tags = {
    Environment = "prod"
  }
}
