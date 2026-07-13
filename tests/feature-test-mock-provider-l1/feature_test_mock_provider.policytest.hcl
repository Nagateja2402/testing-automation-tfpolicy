# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test-framework-only feature: feature_test_mock_provider
# Asserts                    : provider {} block declares a mocked provider configuration
# Targets a shared trivial policy so the focus stays on the test feature itself.
# =============================================================================

policytest {
  targets = ["feature_target_resource.policy.hcl"]
}


provider "aws" "mocked" {
  expect_failure = false
  meta = { type = "aws", version = "5.100.0" }
}
resource "aws_s3_bucket" "uses_provider" {
  expect_failure = false
  attrs = { bucket = "x" }
  meta  = { provider_type = "aws" }
}
