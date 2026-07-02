# Copyright (c) HashiCorp, Inc.

policy {}

resource_policy "aws_s3_bucket" "prod_requires_owner" {
  filter = core::try(attrs.tags.Environment, "") == "production"

  enforce {
    condition     = core::try(attrs.tags.Owner, "") != ""
    error_message = "Production S3 buckets must have an Owner tag"
  }
}
