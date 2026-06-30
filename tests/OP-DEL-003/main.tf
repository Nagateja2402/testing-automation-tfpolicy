# OP-DEL-003: Delete-only policy NOT evaluated on create or update.
# At plan/apply, new resources = create operation → delete-only policy NOT evaluated → PASS.
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
  bucket = "op-del-003-bucket"
  tags = {}
}
