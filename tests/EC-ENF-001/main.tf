# EC-ENF-001: Multiple enforce blocks — first fails (no env tag), second passes (bucket name present).
# Worst result (deny) propagates.
# tfp plan: FAIL (tags are config-known, first enforce condition evaluates to false)
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
  bucket = "ec-enf-001-bucket"
  # Intentionally no Environment tag → first enforce block fails
  tags = {}
}
