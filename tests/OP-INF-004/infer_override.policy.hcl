# Copyright (c) HashiCorp, Inc.
# Tests that explicit meta.operation overrides inference from attrs/prior_attrs.

policy {}

resource_policy "aws_s3_bucket" "create_requires_environment_tag" {
  operations = ["create"]

  enforce {
    condition     = core::try(attrs.tags.Environment, "") != ""
    error_message = "New S3 buckets must have an Environment tag"
  }
}
