# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

policytest {
  targets = ["feature_preplan_provider_meta_version.policy.hcl"]
}

provider "aws" "pass_recent" {
  expect_failure = false
  meta = { type = "aws", version = "5.100.0" }
}

provider "aws" "fail_old" {
  expect_failure = true
  meta = { type = "aws", version = "4.5.0" }
}
