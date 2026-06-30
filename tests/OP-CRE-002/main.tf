# OP-CRE-002: Create-only policy — no Environment tag → FAIL.
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
  bucket = "op-cre-002-bucket"
  # No Environment tag → create-only policy fails
  tags = {}
}
