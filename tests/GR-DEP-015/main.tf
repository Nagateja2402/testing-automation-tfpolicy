# GR-DEP-015: getresources result used in multi-step locals chain
# bucket name is config-known → chain resolves at plan time
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
  bucket        = "gr-dep-015-logging-bucket-xyz"
  force_destroy = true
}

resource "aws_s3_bucket" "primary" {
  bucket        = "gr-dep-015-primary-bucket-xyz"
  force_destroy = true
  # Ensure the logging config resource is planned (and in ChangesSync) before
  # this bucket's policy runs getresources("aws_s3_bucket_logging", ...).
  depends_on = [aws_s3_bucket_logging.primary]
}

resource "aws_s3_bucket_logging" "primary" {
  # Use literal bucket name (not resource reference) to break the dependency
  # on aws_s3_bucket.primary, so this resource can be planned first.
  bucket        = "gr-dep-015-primary-bucket-xyz"
  target_bucket = aws_s3_bucket.logging_bucket.bucket
  target_prefix = "logs/access/"
}
