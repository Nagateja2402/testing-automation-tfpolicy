# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test-framework-only feature: feature_test_mock_data
# Asserts                    : data {} block declares a mocked data source
# Targets a shared trivial policy so the focus stays on the test feature itself.
# =============================================================================

policytest {
  targets = ["feature_target_resource.policy.hcl"]
}


data "aws_ami" "mocked" {
  attrs = { id = "ami-1234", most_recent = true }
}
resource "aws_s3_bucket" "needs_data" {
  expect_failure = false
  attrs = { bucket = "x" }
  meta  = { provider_type = "aws" }
}
