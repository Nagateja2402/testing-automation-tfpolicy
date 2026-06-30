# OP-UPD-001: Update-only immutable bucket name policy — must not change bucket name.
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
  bucket = "op-upd-001-bucket"
  tags = {}
}
