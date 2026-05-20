# Copyright (c) HashiCorp, Inc.
# Policy targets only the "aws" provider type.
# A "google" or "azurerm" provider should not be evaluated by this policy.

policy {}

provider_policy "aws" "must_use_approved_region" {
  locals {
    approved_regions = ["us-east-1", "us-west-2"]
    # region is a provider config attribute — available via attrs, not meta
    region           = core::try(attrs.region, "")
  }

  enforce {
    condition     = core::contains(local.approved_regions, local.region)
    error_message = "AWS provider must use us-east-1 or us-west-2"
  }
}
