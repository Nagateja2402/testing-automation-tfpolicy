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
  # Ensure the logging config resource is planned (and in ChangesSync) before
  # this bucket's policy runs getresources("aws_s3_bucket_logging", ...).
  depends_on = [aws_s3_bucket_logging.primary]
}

resource "aws_s3_bucket_logging" "primary" {
  # Use literal bucket names (not resource references) so that this resource
  # has no dependency on aws_s3_bucket.primary or aws_s3_bucket.logging_bucket.
  # Combined with the depends_on on aws_s3_bucket.primary below, this ensures
  # aws_s3_bucket_logging is planned and written to ChangesSync BEFORE
  # aws_s3_bucket.primary's policy runs its getresources lookups.
  # Literal target_bucket also ensures the second hop (getresources on
  # aws_s3_bucket filtered by target_bucket name) resolves at plan time.
  bucket        = "gr-dep-010-primary-bucket-xyz"
  target_bucket = "gr-dep-010-logging-bucket-xyz"
  target_prefix = "logs/"
}
