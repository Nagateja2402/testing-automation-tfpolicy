# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test for feature: feature_expr_prior_attrs
# Asserts        : prior_attrs visible during update
# =============================================================================

policytest {
  targets = ["feature_expr_prior_attrs.policy.hcl"]
}


resource "aws_s3_bucket" "update_pass" {
  expect_failure = false
  attrs       = { bucket = "new" }
  prior_attrs = { bucket = "old" }

  meta   = { provider_type = "aws", operation = "update" }
}
