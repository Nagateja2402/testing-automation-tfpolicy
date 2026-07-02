# OP-ALL-001: All ops policy — requires ResourceName tag.
# At plan/apply, creating a new bucket with ResourceName tag → PASS.
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
  bucket = "op-all-001-bucket"
  tags = {
    ResourceName = "op-all-001-bucket"
  }
}
