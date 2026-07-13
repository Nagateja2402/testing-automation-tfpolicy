# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test for feature: feature_expr_unknown_handling
# Asserts        : unknown attribute does not produce deny
# =============================================================================

policytest {
  targets = ["feature_expr_unknown_handling.policy.hcl"]
}


resource "aws_s3_bucket" "unknown_pass" {
  expect_failure = false
  attrs = { bucket = "literal-only" }
  meta  = { provider_type = "aws" }
}
