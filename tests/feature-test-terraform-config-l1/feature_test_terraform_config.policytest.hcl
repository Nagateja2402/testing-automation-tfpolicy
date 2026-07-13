# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test-framework-only feature: feature_test_terraform_config
# Asserts                    : terraform_config { required_version = ... } pins the test environment
# Targets a shared trivial policy so the focus stays on the test feature itself.
# =============================================================================

policytest {
  targets = ["feature_target_resource.policy.hcl"]
}


resource "aws_s3_bucket" "pass" {
  expect_failure = false
  attrs = { bucket = "x" }
  meta  = { provider_type = "aws" }
}
