# GR-DEP-007: getresources with empty filter returns all resources of type
# Empty filter has no attribute comparisons — no unknowns at any stage
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

resource "aws_s3_bucket" "bucket_one" {
  bucket        = "gr-dep-007-bucket-one-xyz"
  force_destroy = true
}

resource "aws_s3_bucket" "bucket_two" {
  bucket        = "gr-dep-007-bucket-two-xyz"
  force_destroy = true
}

resource "aws_s3_bucket" "bucket_three" {
  bucket        = "gr-dep-007-bucket-three-xyz"
  force_destroy = true
}
