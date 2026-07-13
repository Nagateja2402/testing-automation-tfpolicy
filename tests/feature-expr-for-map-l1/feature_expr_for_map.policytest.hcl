# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test for feature: feature_expr_for_map
# Asserts        : for-map filters empty values
# =============================================================================

policytest {
  targets = ["feature_expr_for_map.policy.hcl"]
}


resource "aws_instance" "pass" {
  expect_failure = false
  attrs = { tags = { owner = "team-a" } }
  meta  = { provider_type = "aws" }
}
resource "aws_instance" "fail" {
  expect_failure = true
  attrs = { tags = { env = "prod" } }
  meta  = { provider_type = "aws" }
}
