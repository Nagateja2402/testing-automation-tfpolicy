# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test-framework-only feature: feature_test_mock_resource
# Asserts                    : resource {} block declares a mocked Terraform resource for evaluation
# Targets a shared trivial policy so the focus stays on the test feature itself.
# =============================================================================

policytest {
  targets = ["feature_target_resource.policy.hcl"]
}


resource "aws_s3_bucket" "mocked" {
  expect_failure = false
  attrs = { bucket = "mock" }
  meta  = { provider_type = "aws" }
}
