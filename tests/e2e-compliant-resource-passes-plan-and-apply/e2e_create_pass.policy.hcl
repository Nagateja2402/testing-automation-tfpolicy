# Copyright (c) HashiCorp, Inc.
# TF-E2E-001: Full lifecycle — create with policy pass.

policy {}

resource_policy "aws_vpc" "must_have_environment_tag" {
  enforce {
    condition     = core::try(attrs.tags.Environment, "") != ""
    error_message = "VPC must have an Environment tag"
  }
}
