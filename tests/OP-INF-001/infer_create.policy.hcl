# Copyright (c) HashiCorp, Inc.
# No operations attribute; default is create+update.
# Tests that when only attrs is provided, operation is inferred as "create".

policy {}

resource_policy "aws_s3_bucket" "create_requires_environment_tag" {
  operations = ["create"]

  enforce {
    condition     = core::try(attrs.tags.Environment, "") != ""
    error_message = "New S3 buckets must have an Environment tag"
  }
}
