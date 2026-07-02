# OP-UPD-003: Update-only policy NOT evaluated on create.
# In L2/L3, new bucket is always "create" → update-only policy NOT evaluated → PASS.
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
  bucket = "op-upd-003-bucket"
  tags = {}
}
