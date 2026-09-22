# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test for feature: feature_expr_meta_tfe_scope
# Asserts        : meta.tfe_workspace / meta.tfe_stack resolve without a
#                  validation error
# =============================================================================

policytest {
  targets = ["feature_expr_meta_tfe_scope.policy.hcl"]
}

resource "aws_s3_bucket" "pass_workspace_scoped" {
  expect_failure = false
  attrs = { bucket = "x" }
  meta = {
    provider_type = "aws"
    tfe_workspace = "prod-workspace"
  }
}
