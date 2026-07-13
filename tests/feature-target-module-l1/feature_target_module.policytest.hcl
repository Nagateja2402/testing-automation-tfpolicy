# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test for feature: feature_target_module
# Asserts        : module block is evaluated
# =============================================================================

policytest {
  targets = ["feature_target_module.policy.hcl"]
}


module "./modules/example" "pass" {
  expect_failure = false
  meta = { source = "./modules/ec2", version = "1.0.0" }
}
