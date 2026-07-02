# GR-DEP-014: Multiple policies both calling getresources on shared resource
# bucket name is config-known → both policies resolve at plan time
# Plan: PASS, Apply: PASS

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
  bucket        = "gr-dep-014-logging-bucket-xyz"
  force_destroy = true
}

resource "aws_s3_bucket" "primary" {
  bucket        = "gr-dep-014-primary-bucket-xyz"
  force_destroy = true
}

resource "aws_s3_bucket_logging" "primary" {
  # Use literal bucket name (not resource reference) to break the dependency
  # on aws_s3_bucket.primary, so this resource can be planned first.
  bucket        = "gr-dep-014-primary-bucket-xyz"
  target_bucket = "gr-dep-014-logging-bucket-xyz"
  target_prefix = "access-logs/"
  # Explicit depends_on ensures both buckets exist before logging is configured.
  depends_on = [aws_s3_bucket.primary, aws_s3_bucket.logging_bucket]
}
