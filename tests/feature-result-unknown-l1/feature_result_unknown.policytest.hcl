# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test for feature: feature_result_unknown
# Asserts        : missing attribute yields unknown, not deny
# =============================================================================

policytest {
  targets = ["feature_result_unknown.policy.hcl"]
}


# The rule reads attrs.maybe_unknown, which isn't in the mock attrs, so the
# condition is unknown and the test framework reports a failure. The asserted
# behaviour is "unknown propagates and surfaces as a failure" — the policy
# does not flip to Deny on its own.
resource "aws_s3_bucket" "unknown_surfaces_as_failure" {
  expect_failure = true
  attrs = { bucket = "x" }
  meta  = { provider_type = "aws" }
}
