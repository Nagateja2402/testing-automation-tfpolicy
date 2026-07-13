# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test-framework-only feature: feature_test_skip_attribute
# Asserts                    : skip = true makes a resource visible to getresources() but excludes it from evaluation
# Targets a shared trivial policy so the focus stays on the test feature itself.
# =============================================================================

policytest {
  targets = ["feature_target_resource.policy.hcl"]
}


resource "aws_s3_bucket" "lookup_target" {
  skip = true
  attrs = { bucket = "lookup-target" }
  meta  = { provider_type = "aws" }
}
resource "aws_s3_bucket" "evaluated" {
  expect_failure = false
  attrs = { bucket = "x" }
  meta  = { provider_type = "aws" }
}
