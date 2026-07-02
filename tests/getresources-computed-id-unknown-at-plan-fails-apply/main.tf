# GR-PLAN-001: Filter getresources on computed id — plan unknown, apply pass
# attrs.id is computed (unknown at plan); unknown filter → resource treated as match → condition unknown
# Apply: id resolved, exact match found → pass

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

resource "aws_s3_bucket" "logging_bucket" {
  bucket        = "gr-plan-001-logging-bucket-xyz"
  force_destroy = true
}

resource "aws_s3_bucket" "primary" {
  bucket        = "gr-plan-001-primary-bucket-xyz"
  force_destroy = true
}

resource "aws_s3_bucket_logging" "primary" {
  bucket        = aws_s3_bucket.primary.id
  target_bucket = aws_s3_bucket.logging_bucket.id
  target_prefix = "logs/"
}
