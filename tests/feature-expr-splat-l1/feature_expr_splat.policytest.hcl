# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test for feature: feature_expr_splat
# Asserts        : splat reads from_port from every ingress rule
# =============================================================================

policytest {
  targets = ["feature_expr_splat.policy.hcl"]
}


resource "aws_security_group" "pass" {
  expect_failure = false
  attrs = {
    ingress = [
      { from_port = 22, to_port = 22 },
      { from_port = 443, to_port = 443 },
    ]
  }
  meta = { provider_type = "aws" }
}
