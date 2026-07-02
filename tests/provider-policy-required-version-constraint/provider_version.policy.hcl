# Copyright (c) HashiCorp, Inc.

policy {}

provider_policy "aws" "must_pin_version" {
  locals {
    version = core::try(meta.version, "")
  }

  enforce {
    condition     = local.version != ""
    error_message = "AWS provider version must be pinned"
  }
}
