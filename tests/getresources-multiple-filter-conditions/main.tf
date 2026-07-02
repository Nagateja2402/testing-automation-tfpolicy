# GR-DEP-008: getresources with multi-attribute filter (region + acl)
# Both filter attributes are config-known → exact match at plan and apply
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

resource "aws_s3_bucket" "private_us_east" {
  bucket        = "gr-dep-008-private-us-east-xyz"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "private_us_east" {
  bucket = aws_s3_bucket.private_us_east.id
  rule { object_ownership = "BucketOwnerPreferred" }
}

resource "aws_s3_bucket_acl" "private_us_east" {
  depends_on = [aws_s3_bucket_ownership_controls.private_us_east]
  bucket     = aws_s3_bucket.private_us_east.id
  acl        = "private"
}

resource "aws_s3_bucket" "primary" {
  bucket        = "gr-dep-008-primary-xyz"
  force_destroy = true
  tags = {
    region = "us-east-1"
  }
}
