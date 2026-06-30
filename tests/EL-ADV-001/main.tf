# EL-ADV-001: Advisory enforcement — failure produces a warning, does not block.
# Bucket has no versioning → advisory condition fails → Warning (not Error) → PASS (not blocked)
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
  bucket = "el-adv-001-bucket"
  # No versioning → advisory condition fails → Warning only, not blocked
  tags = { Environment = "dev" }
}
