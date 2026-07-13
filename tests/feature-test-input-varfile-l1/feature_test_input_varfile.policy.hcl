# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_test_input_varfile (policy half)
# Covers : a policy that reads inputs intended to be supplied via a
#          .policyvars.hcl file passed to `tfpolicy test --input-file ...`.
# =============================================================================

input "max_buckets" {
  type    = number
  default = 0   # default of 0 makes the "no varfile" path fail; the varfile
                # raises it to a permissive number.
}

input "blocked_regions" {
  type    = list(string)
  # Default contains 'ap-southeast-1' so the "fail" case fails even without
  # `--input-file`. The varfile (feature_test_input_varfile.policyvars.hcl)
  # demonstrates overriding this list with a different blocked set.
  default = ["ap-southeast-1"]
}

resource_policy "aws_s3_bucket" "feature_test_input_varfile_region" {
  locals {
    region = core::try(attrs.region, "us-east-1")
  }

  enforce {
    condition     = !core::contains(input.blocked_regions, local.region)
    error_message = "bucket region '${local.region}' is in the varfile blocked_regions list"
  }
}
