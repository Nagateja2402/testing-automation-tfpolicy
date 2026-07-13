# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test for feature: feature_expr_for_list
# Asserts        : for-list filters by predicate
# =============================================================================

policytest {
  targets = ["feature_expr_for_list.policy.hcl"]
}


resource "aws_security_group" "pass" {
  expect_failure = false
  attrs = { ingress = [{ from_port = 22, cidr = "10.0.0.0/8" }] }
  meta  = { provider_type = "aws" }
}
