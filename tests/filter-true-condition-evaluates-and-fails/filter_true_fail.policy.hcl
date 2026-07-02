# Copyright (c) HashiCorp, Inc.

policy {}

resource_policy "aws_s3_bucket" "filter_skip_non_prod" {
  filter = core::try(attrs.tags.Environment, "") == "production"

  enforce {
    condition     = core::try(attrs.versioning_enabled, false) == true
    error_message = "Production S3 buckets must have versioning enabled"
  }
}
