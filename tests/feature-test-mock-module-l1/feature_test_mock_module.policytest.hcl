# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test-framework-only feature: feature_test_mock_module
# Asserts                    : module {} block declares a mocked module instantiation
# Targets a shared trivial policy so the focus stays on the test feature itself.
# =============================================================================

policytest {
  targets = ["feature_target_resource.policy.hcl"]
}


module "./modules/example" "mocked" {
  expect_failure = false
  meta = { source = "./modules/ec2", version = "1.0.0" }
}
resource "aws_s3_bucket" "alongside_module" {
  expect_failure = false
  attrs = { bucket = "x" }
  meta  = { provider_type = "aws" }
}
