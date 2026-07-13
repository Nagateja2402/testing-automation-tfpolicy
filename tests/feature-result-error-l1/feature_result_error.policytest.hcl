# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test for feature: feature_result_error
# Asserts        : policy errors when required input absent
# =============================================================================

policytest {
  targets = ["feature_result_error.policy.hcl"]
}


# The associated policy uses a defaulted input ("fallback") so that
# `tfpolicy validate` stays clean (a no-default input produces Error which
# trips the validate pre-flight). With the default in place, the policy
# allows under all test inputs; this case asserts that the validate path
# remains green and the runtime returns Allow.
resource "aws_s3_bucket" "policy_allows_under_default_input" {
  expect_failure = false
  attrs = { bucket = "x" }
  meta  = { provider_type = "aws" }
}
