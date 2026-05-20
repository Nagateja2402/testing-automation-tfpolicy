# Copyright (c) HashiCorp, Inc.
# Advisory enforcement: failure produces a warning, does not block.

policy {}

resource_policy "aws_s3_bucket" "advisory_versioning_check" {
  enforcement_level = "advisory"

  enforce {
    condition     = core::try(attrs.versioning_enabled, false) == true
    error_message = "Advisory: S3 buckets should have versioning enabled"
  }
}
