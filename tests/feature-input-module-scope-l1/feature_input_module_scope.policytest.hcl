# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test for: feature_input_module_scope_{definer,consumer}.policy.hcl
# Asserts : a top-level `input "..." {}` declared in the definer file is
#           resolvable as `input.<name>` from the consumer file.
# =============================================================================

policytest {
  targets = ["feature_input_module_scope_consumer.policy.hcl"]
}

# ---- Bucket prefix rule -----------------------------------------------------

resource "aws_s3_bucket" "pass_prefix" {
  expect_failure = false
  attrs = { bucket = "regression-bucket" }
  meta  = { provider_type = "aws" }
}

resource "aws_s3_bucket" "fail_wrong_prefix" {
  expect_failure = true
  attrs = { bucket = "prod-data" }
  meta  = { provider_type = "aws" }
}

# ---- Required-tag-keys rule -------------------------------------------------

resource "aws_instance" "pass_all_tags" {
  expect_failure = false
  attrs = {
    tags = {
      owner       = "team-a"
      environment = "regression"
      extra       = "ignored"
    }
  }
  meta = { provider_type = "aws" }
}

resource "aws_instance" "fail_missing_owner" {
  expect_failure = true
  attrs = {
    tags = {
      environment = "regression"
    }
  }
  meta = { provider_type = "aws" }
}

# ---- Max-capacity rule ------------------------------------------------------

resource "aws_autoscaling_group" "pass_at_cap" {
  expect_failure = false
  attrs = { desired_capacity = 5 }
  meta  = { provider_type = "aws" }
}

resource "aws_autoscaling_group" "fail_over_cap" {
  expect_failure = true
  attrs = { desired_capacity = 9 }
  meta  = { provider_type = "aws" }
}
