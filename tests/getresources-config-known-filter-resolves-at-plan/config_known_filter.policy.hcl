# Copyright (c) HashiCorp, Inc.

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}
resource_policy "aws_s3_bucket" "must_have_logging_by_bucket_name" {
  # Only evaluate primary buckets; skip dedicated logging-target buckets.
  filter = !core::endswith(attrs.bucket, "-logging-bucket-xyz")
  locals {
    # Filter on bucket name — config-known, not computed → resolves at plan time
    logging_configs = core::getresources("aws_s3_bucket_logging", {
      bucket = attrs.bucket
    })
  }

  enforce {
    condition     = core::length(local.logging_configs) > 0
    error_message = "S3 bucket must have access logging configured"
  }
}
