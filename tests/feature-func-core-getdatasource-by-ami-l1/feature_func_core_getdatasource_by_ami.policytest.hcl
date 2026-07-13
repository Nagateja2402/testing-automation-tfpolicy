# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test for feature: feature_func_core_getdatasource_by_ami
# Asserts        : core::getdatasource resolves the aws_ami data source whose
#                  id matches the instance's ami attribute
# =============================================================================

policytest {
  targets = ["feature_func_core_getdatasource_by_ami.policy.hcl"]
}

# Data source whose `filter` block matches the one the policy builds from the
# instance's ami attribute, so core::getdatasource resolves to this block.
data "aws_ami" "selected" {
  attrs = {
    id           = "ami-0abcdef1234567890"
    architecture = "x86_64"
    filter = [{
      name   = "image-id"
      values = ["ami-0abcdef1234567890"]
    }]
  }
}

resource "aws_instance" "pass" {
  expect_failure = false
  attrs = { ami = "ami-0abcdef1234567890" }
  meta  = { provider_type = "aws" }
}
