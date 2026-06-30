# OP-DEL-002: Delete-only policy — missing DeletionApproved tag → FAIL on delete.
# At plan/apply, new resource = create operation → delete-only policy NOT evaluated → PASS.
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
  bucket = "op-del-002-bucket"
  tags = {}
}
