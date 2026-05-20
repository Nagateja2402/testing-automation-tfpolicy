# Copyright (c) HashiCorp, Inc.
# Mandatory overridable enforcement: failure can be overridden.

policy {}

resource_policy "aws_s3_bucket" "overridable_versioning_check" {
  enforcement_level = "mandatory_overridable"

  enforce {
    condition     = core::try(attrs.versioning_enabled, false) == true
    error_message = "Overridable: S3 buckets should have versioning enabled"
  }
}
