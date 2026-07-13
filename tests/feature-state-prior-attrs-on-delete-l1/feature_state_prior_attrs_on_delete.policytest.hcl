# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test for feature: feature_state_prior_attrs_on_delete
# Asserts        : prior_attrs visible during delete
# =============================================================================

policytest {
  targets = ["feature_state_prior_attrs_on_delete.policy.hcl"]
}


resource "aws_s3_bucket" "pass" {
  expect_failure = false
  prior_attrs = { bucket = "to-delete" }

  meta   = { provider_type = "aws", operation = "delete" }
}
