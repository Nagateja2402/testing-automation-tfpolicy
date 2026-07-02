# Copyright (c) HashiCorp, Inc.

policy {}

resource_policy "aws_s3_bucket" "bucket_name_pattern" {
  locals {
    bucket_name    = core::try(attrs.bucket, "")
    naming_pattern = "^[a-z][a-z0-9-]{1,61}[a-z0-9]$"
  }

  enforce {
    condition     = local.bucket_name != "" && core::length(core::regexall(local.naming_pattern, local.bucket_name)) > 0
    error_message = "S3 bucket name '${local.bucket_name}' must be 3-63 chars, start lowercase, and contain only lowercase letters, numbers, and hyphens"
  }
}
