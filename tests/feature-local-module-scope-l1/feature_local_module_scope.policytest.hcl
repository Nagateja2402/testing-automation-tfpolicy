# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test for: feature_local_module_scope_{definer,consumer}.policy.hcl
# Asserts : a top-level `locals {}` declared in the definer file is
#           resolvable as `local.<name>` from the consumer file.
# =============================================================================

policytest {
  targets = ["feature_local_module_scope_consumer.policy.hcl"]
}

# ---- Bucket resource (consumer's resource_policy) ---------------------------

resource "aws_s3_bucket" "pass_prefix_and_length" {
  expect_failure = false
  attrs = { bucket = "regression-okay" }
  meta  = { provider_type = "aws" }
}

resource "aws_s3_bucket" "fail_wrong_prefix" {
  expect_failure = true
  attrs = { bucket = "not-regression" }
  meta  = { provider_type = "aws" }
}

resource "aws_s3_bucket" "fail_too_long" {
  expect_failure = true
  attrs = { bucket = "regression-this-name-is-way-way-too-long-for-the-module-cap" }
  meta  = { provider_type = "aws" }
}

# ---- Provider (consumer's provider_policy) ----------------------------------

provider "aws" "pass_allowed_region" {
  expect_failure = false
  attrs = { region = "us-east-1" }
  meta  = { type = "aws", version = "5.100.0" }
}

provider "aws" "fail_disallowed_region" {
  expect_failure = true
  attrs = { region = "ap-southeast-1" }
  meta  = { type = "aws", version = "5.100.0" }
}
