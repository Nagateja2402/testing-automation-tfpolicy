# Copyright (c) HashiCorp, Inc.

policy {}

resource_policy "aws_s3_bucket" "check_logging_exists" {
  locals {
    logging_configs = core::getresources("aws_s3_bucket_logging", {
      bucket = attrs.bucket
    })
  }

  enforce {
    condition     = core::length(local.logging_configs) > 0
    error_message = "S3 bucket must have access logging configured (policy 1 of 2)"
  }
}

resource_policy "aws_s3_bucket" "check_logging_target_prefix" {
  locals {
    logging_configs = core::getresources("aws_s3_bucket_logging", {
      bucket = attrs.bucket
    })
    prefix = core::length(local.logging_configs) > 0 ? core::try(local.logging_configs[0].target_prefix, "") : ""
  }

  enforce {
    condition     = local.prefix != ""
    error_message = "S3 bucket logging must have a target_prefix set (policy 2 of 2)"
  }
}
