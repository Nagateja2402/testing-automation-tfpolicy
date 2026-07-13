# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test-framework-only feature: feature_test_expect_failure_true
# Asserts                    : expect_failure = true asserts the policy denies
# Targets a shared trivial policy so the focus stays on the test feature itself.
# =============================================================================

policytest {
  # Target a policy that denies unconditionally so the expect_failure=true
  # semantic is actually exercised. feature_target_resource.policy.hcl is
  # trivial (condition=true), so it never denies and can't anchor this test.
  targets = ["feature_result_deny.policy.hcl"]
}


resource "aws_s3_bucket" "denied" {
  expect_failure = true
  attrs = { bucket = "" }
  meta  = { provider_type = "aws" }
}
