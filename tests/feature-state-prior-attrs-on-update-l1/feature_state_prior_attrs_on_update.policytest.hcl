# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test for feature: feature_state_prior_attrs_on_update
# Asserts        : prior_attrs visible during update
# =============================================================================

policytest {
  targets = ["feature_state_prior_attrs_on_update.policy.hcl"]
}


resource "aws_s3_bucket" "pass" {
  expect_failure = false
  attrs       = { bucket = "new" }
  prior_attrs = { bucket = "old" }

  meta   = { provider_type = "aws", operation = "update" }
}
