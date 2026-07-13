# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test-framework-only feature: feature_test_locals
# Asserts                    : test-level locals provide fixture values to test cases
# Targets a shared trivial policy so the focus stays on the test feature itself.
# =============================================================================

policytest {
  targets = ["feature_target_resource.policy.hcl"]
}


locals {
  expected_bucket = "fixture"
}
resource "aws_s3_bucket" "pass" {
  expect_failure = false
  attrs = { bucket = local.expected_bucket }
  meta  = { provider_type = "aws" }
}
