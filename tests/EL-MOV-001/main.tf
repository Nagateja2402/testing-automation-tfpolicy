# EL-MOV-001: Mandatory overridable enforcement — failure produces Error (same as mandatory).
# Bucket has no versioning → condition fails → FAIL
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
  bucket = "el-mov-001-bucket"
  # No versioning_enabled = true → mandatory_overridable condition fails
  tags = { Environment = "dev" }
}
