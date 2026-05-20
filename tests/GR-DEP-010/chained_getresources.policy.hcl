# Copyright (c) HashiCorp, Inc.

policy {}

resource_policy "aws_s3_bucket" "must_have_logging_configured" {
  locals {
    # First hop: find logging config for this bucket
    logging_configs = core::getresources("aws_s3_bucket_logging", {
      bucket = attrs.bucket
    })
    has_logging = core::length(local.logging_configs) > 0
    target_bucket_name = local.has_logging ? core::try(local.logging_configs[0].target_bucket, "") : ""

    # Second hop: verify the target logging bucket itself exists
    logging_buckets = local.target_bucket_name != "" ? core::getresources("aws_s3_bucket", {
      bucket = local.target_bucket_name
    }) : []
  }

  enforce {
    condition     = local.has_logging
    error_message = "S3 bucket must have access logging configured"
  }

  enforce {
    condition     = core::length(local.logging_buckets) > 0
    error_message = "S3 bucket logging target must be a bucket managed in this configuration"
  }
}
