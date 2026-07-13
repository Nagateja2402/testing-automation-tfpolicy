# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

policytest {
  targets = ["feature_preplan_provider_meta_type.policy.hcl"]
}

provider "aws" "pass_aws" {
  expect_failure = false
  meta = { type = "aws", version = "5.100.0" }
}

provider "azurerm" "fail_non_aws" {
  expect_failure = true
  meta = { type = "azurerm", version = "3.0.0" }
}
