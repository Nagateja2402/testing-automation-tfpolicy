# OP-INF-003: Operation inferred as "delete" when only prior_attrs provided.
# In L2/L3, new bucket is always "create" → delete policy not evaluated → PASS.
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
  bucket = "op-inf-003-bucket"
  tags = {}
}
