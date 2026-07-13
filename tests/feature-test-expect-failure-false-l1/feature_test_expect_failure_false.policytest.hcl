# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test-framework-only feature: feature_test_expect_failure_false
# Asserts                    : expect_failure = false asserts the policy allows
# Targets a shared trivial policy so the focus stays on the test feature itself.
# =============================================================================

policytest {
  targets = ["feature_target_resource.policy.hcl"]
}


resource "aws_s3_bucket" "allowed" {
  expect_failure = false
  attrs = { bucket = "ok" }
  meta  = { provider_type = "aws" }
}
