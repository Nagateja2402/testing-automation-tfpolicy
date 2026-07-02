# Copyright (c) HashiCorp, Inc.
# TF-E2E-002: Full lifecycle — create blocked by mandatory policy.

policy {}

resource_policy "aws_vpc" "must_have_environment_tag" {
  enforce {
    condition     = core::try(attrs.tags.Environment, "") != ""
    error_message = "VPC must have an Environment tag"
  }
}
