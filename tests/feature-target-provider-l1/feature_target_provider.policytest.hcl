# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test for feature: feature_target_provider
# Asserts        : provider block is evaluated
# =============================================================================

policytest {
  targets = ["feature_target_provider.policy.hcl"]
}


provider "aws" "pass" {
  expect_failure = false
  meta = { type = "aws", version = "5.100.0" }
}
