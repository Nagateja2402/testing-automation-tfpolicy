# Copyright (c) HashiCorp, Inc.
# REG-BIN-004: Provider policy unaffected by binary change.

policy {}

provider_policy "aws" "must_use_approved_region" {
  locals {
    approved_regions = ["us-east-1", "us-west-2"]
    region           = core::try(meta.region, "")
  }

  enforce {
    condition     = core::contains(local.approved_regions, local.region)
    error_message = "AWS provider must use an approved region"
  }
}
