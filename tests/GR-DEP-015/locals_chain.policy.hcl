# Copyright (c) HashiCorp, Inc.

policy {}

resource_policy "aws_s3_bucket" "check_logging_chain" {
  locals {
    # Step A: fetch related resource
    logging_configs = core::getresources("aws_s3_bucket_logging", {
      bucket = attrs.bucket
    })
    # Step B: derive from step A
    has_logging = core::length(local.logging_configs) > 0
    # Step C: derive from step B
    target_prefix = local.has_logging ? core::try(local.logging_configs[0].target_prefix, "") : ""
    # Step D: final check
    prefix_is_valid = core::startswith(local.target_prefix, "logs/")
  }

  enforce {
    condition     = local.has_logging
    error_message = "S3 bucket must have access logging enabled"
  }

  enforce {
    condition     = local.prefix_is_valid
    error_message = "S3 bucket logging target_prefix must start with 'logs/'"
  }
}
