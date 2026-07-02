# OP-CRE-001: Create-only policy — requires Environment tag. New bucket with tag → PASS.
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
  bucket = "op-cre-001-bucket"
  tags = {
    Environment = "dev"
  }
}
