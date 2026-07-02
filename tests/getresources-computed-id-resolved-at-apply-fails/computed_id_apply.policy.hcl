# Copyright (c) HashiCorp, Inc.

policy {}

resource_policy "aws_s3_bucket" "must_have_logging_by_id" {
  locals {
    logging_configs = core::getresources("aws_s3_bucket_logging", {
      id = attrs.id
    })
  }

  enforce {
    condition     = core::length(local.logging_configs) > 0
    error_message = "S3 bucket must have access logging configured"
  }
}
