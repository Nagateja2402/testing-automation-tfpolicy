# EL-MND-001: Mandatory enforcement — failure blocks the run.
# Bucket has no versioning → mandatory condition fails → FAIL
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
  bucket = "el-mnd-001-bucket"
  # No versioning_enabled = true → mandatory condition fails
  tags = { Environment = "dev" }
}
