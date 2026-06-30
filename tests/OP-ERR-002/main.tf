# OP-ERR-002: Create-only policy, prior_attrs present but not a validation error.
# New bucket with Environment tag → PASS.
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
  bucket = "op-err-002-bucket"
  tags = {
    Environment = "dev"
  }
}
