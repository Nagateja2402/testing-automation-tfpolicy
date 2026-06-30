# EL-RES-001: Policy-level advisory default overridden by resource_policy mandatory.
# Bucket has no versioning → mandatory override makes it FAIL
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
  bucket = "el-res-001-bucket"
  # No versioning_enabled = true → resource_policy mandatory enforcement fails
  tags = { Environment = "dev" }
}
