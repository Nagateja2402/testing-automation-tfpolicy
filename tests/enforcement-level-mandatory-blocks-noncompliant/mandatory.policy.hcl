# Copyright (c) HashiCorp, Inc.
# Mandatory enforcement (default): failure blocks the run.

policy {}

resource_policy "aws_s3_bucket" "mandatory_versioning_check" {
  enforcement_level = "mandatory"

  enforce {
    condition     = core::try(attrs.versioning_enabled, false) == true
    error_message = "Mandatory: S3 buckets must have versioning enabled"
  }
}
