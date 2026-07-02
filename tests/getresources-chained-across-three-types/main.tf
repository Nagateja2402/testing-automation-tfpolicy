# GR-DEP-010: Chained getresources A→B→C
# bucket name is config-known → both hops resolve at plan time
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
  bucket        = "gr-dep-010-logging-bucket-xyz"
  force_destroy = true
}

resource "aws_s3_bucket" "primary" {
  bucket        = "gr-dep-010-primary-bucket-xyz"
  force_destroy = true
}

resource "aws_s3_bucket_logging" "primary" {
  # Use literal bucket names (not resource references) so that this resource
  # has no implicit dependency on aws_s3_bucket.primary or aws_s3_bucket.logging_bucket.
  # Literal target_bucket also ensures the second hop (getresources on
  # aws_s3_bucket filtered by target_bucket name) resolves at plan time.
  bucket        = "gr-dep-010-primary-bucket-xyz"
  target_bucket = "gr-dep-010-logging-bucket-xyz"
  target_prefix = "logs/"
  # Explicit depends_on ensures both source and target buckets exist before
  # aws_s3_bucket_logging is created (PutBucketLogging requires both to exist).
  depends_on = [aws_s3_bucket.primary, aws_s3_bucket.logging_bucket]
}
