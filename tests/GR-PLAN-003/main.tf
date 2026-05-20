# GR-PLAN-003: getresources filter on config-known bucket name
# bucket is set in config (not computed) → exact match at plan time → PASS at plan and apply

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
  bucket        = "gr-plan-003-logging-bucket-xyz"
  force_destroy = true
}

resource "aws_s3_bucket" "primary" {
  bucket        = "gr-plan-003-primary-bucket-xyz"
  force_destroy = true
  # Ensure the logging config resource is planned (and in ChangesSync) before
  # this bucket's policy runs getresources("aws_s3_bucket_logging", ...).
  depends_on = [aws_s3_bucket_logging.primary]
}

resource "aws_s3_bucket_logging" "primary" {
  # Use literal bucket name (not resource reference) to break the dependency
  # on aws_s3_bucket.primary, so this resource can be planned first.
  bucket        = "gr-plan-003-primary-bucket-xyz"
  target_bucket = aws_s3_bucket.logging_bucket.bucket
  target_prefix = "logs/"
}
