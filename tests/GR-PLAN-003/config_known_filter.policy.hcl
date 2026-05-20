# Copyright (c) HashiCorp, Inc.

policy {}

resource_policy "aws_s3_bucket" "must_have_logging_by_bucket_name" {
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
