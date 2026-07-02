# GR-DEP-013: getresources to find a -logs bucket partner.
# Filter: getresources("aws_s3_bucket", {bucket = "${attrs.bucket}-logs"})
# attrs.bucket is a literal → config-known at plan time.
# Both primary and logs buckets defined → filter matches → condition passes → PASS.
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

resource "aws_s3_bucket" "primary" {
  bucket = "gr-dep-013-primary"
  tags   = {}
}

resource "aws_s3_bucket" "logs" {
  bucket = "gr-dep-013-primary-logs"
  tags   = {}
}
