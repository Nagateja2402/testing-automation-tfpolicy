# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

policytest {
  targets = ["feature_preplan_module_meta_source.policy.hcl"]
}

module "./modules/example" "pass_local" {
  expect_failure = false
  meta = { source = "./modules/example", version = "1.0.0" }
}

module "registry.terraform.io/hashicorp/aws-vpc" "pass_registry" {
  expect_failure = false
  meta = { source = "registry.terraform.io/hashicorp/aws-vpc", version = "1.2.3" }
}

module "github.com/forks/random-module" "fail_unapproved" {
  expect_failure = true
  meta = { source = "github.com/forks/random-module", version = "0.0.1" }
}
