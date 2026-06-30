# OP-DEL-001: Delete-only policy — requires DeletionApproved tag before deletion.
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
  bucket = "op-del-001-bucket"
  # No DeletionApproved tag, but policy only runs on delete → PASS
  tags = {}
}
