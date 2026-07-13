# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test for feature: feature_expr_type_conversion
# Asserts        : numeric attr compared via implicit coercion
# =============================================================================

policytest {
  targets = ["feature_expr_type_conversion.policy.hcl"]
}


resource "aws_instance" "pass_with_count" {
  expect_failure = false
  attrs = { ipv6_address_count = 2 }
  meta  = { provider_type = "aws" }
}

resource "aws_instance" "pass_unset" {
  expect_failure = false
  attrs = {}
  meta  = { provider_type = "aws" }
}
