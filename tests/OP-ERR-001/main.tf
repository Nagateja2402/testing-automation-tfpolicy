# OP-ERR-001: Policy uses prior_attrs without create operation → update+delete scope.
# At plan, creating a new bucket (create) → policy not evaluated → PASS.
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
  bucket = "op-err-001-bucket"
  tags = {}
}
