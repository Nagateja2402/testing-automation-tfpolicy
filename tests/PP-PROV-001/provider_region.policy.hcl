# Copyright (c) HashiCorp, Inc.

policy {}

provider_policy "aws" "must_use_approved_region" {
  locals {
    approved_regions = ["us-east-1", "us-west-2", "eu-west-1"]
    # region is a provider config attribute — available via attrs, not meta
    region           = core::try(attrs.region, "")
  }

  enforce {
    condition     = core::contains(local.approved_regions, local.region)
    error_message = "AWS provider must use an approved region (us-east-1, us-west-2, or eu-west-1)"
  }
}
