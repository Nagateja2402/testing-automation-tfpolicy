# OP-ALL-002: All ops policy — requires ResourceName tag. Missing tag → FAIL.
# tfp plan: FAIL
# tfp apply: FAIL

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
  bucket = "op-all-002-bucket"
  # No ResourceName tag → policy fails
  tags = {}
}
