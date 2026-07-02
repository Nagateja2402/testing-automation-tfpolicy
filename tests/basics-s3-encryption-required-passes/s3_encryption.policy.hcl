# Copyright (c) HashiCorp, Inc.

policy {}

resource_policy "aws_s3_bucket" "must_have_env_tag" {
  locals {
    env = core::try(attrs.tags.Environment, "")
  }

  enforce {
    condition     = local.env != ""
    error_message = "S3 bucket must have an Environment tag"
  }
}
