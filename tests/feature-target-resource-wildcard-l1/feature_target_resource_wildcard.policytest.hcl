# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test for feature: feature_target_resource_wildcard
# Asserts        : wildcard target matches multiple resource types
# =============================================================================

policytest {
  targets = ["feature_target_resource_wildcard.policy.hcl"]
}


resource "aws_s3_bucket" "pass_s3" {
  expect_failure = false
  attrs = { bucket = "a" }
  meta  = { provider_type = "aws" }
}
resource "aws_instance" "pass_ec2" {
  expect_failure = false
  attrs = { instance_type = "t3.micro" }
  meta  = { provider_type = "aws" }
}
