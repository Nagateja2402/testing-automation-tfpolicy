# Copyright (c) HashiCorp, Inc.

policy {}

resource_policy "aws_s3_bucket" "must_have_companion_resource" {
  locals {
    companions = core::getresources("aws_nonexistent_resource_type", {})
  }

  enforce {
    condition     = core::length(local.companions) > 0
    error_message = "No resources of type 'aws_nonexistent_resource_type' found in the configuration"
  }
}
