# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test for feature: feature_metaarg_enforcement_overridable
# Asserts        : overridable diagnostic surfaces
# =============================================================================

policytest {
  targets = ["feature_metaarg_enforcement_overridable.policy.hcl"]
}


resource "aws_s3_bucket" "fail" {
  expect_failure = true
  attrs = { bucket = "x" }
  meta  = { provider_type = "aws" }
}
