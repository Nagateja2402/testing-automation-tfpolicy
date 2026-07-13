# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

policytest {
  targets = ["feature_preplan_module_meta_version.policy.hcl"]
}

module "./modules/example" "pass_v1" {
  expect_failure = false
  meta = { source = "./modules/example", version = "1.2.3" }
}

module "./modules/example" "fail_v0" {
  expect_failure = true
  meta = { source = "./modules/example", version = "0.9.0" }
}
