# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test for feature: feature_func_core_valuetostring
# Asserts        : core::valuetostring renders unknown/null leaves as sentinels
#                  and never hard-fails, even when attrs contain unknown values
# =============================================================================

policytest {
  targets = ["feature_func_core_valuetostring.policy.hcl"]
}

# =============================================================================
# Reference resources — skip = true so they are available to
# core::getresources() but are not evaluated as test cases themselves.
# =============================================================================

# Fully-known encryption config: all relevant attrs present.
# core::valuetostring(configs) can serialize the entire object without
# encountering any unknown leaves.
resource "aws_s3_bucket_server_side_encryption_configuration" "for_known_bucket" {
  skip = true
  attrs = {
    bucket = "my-bucket"
    rule = [{
      apply_server_side_encryption_by_default = [{
        sse_algorithm     = "aws:kms"
        kms_master_key_id = "arn:aws:kms:us-east-1:123456789012:key/abc"
      }]
    }]
  }
  meta = { provider_type = "aws" }
}

# Partially-known encryption config: "kms_master_key_id" is omitted so it is
# unknown at evaluation time, matching real plan-time behaviour.
# Before the fix, core::valuetostring would abort on the unknown leaf; after
# the fix it renders it as "(unknown)".
resource "aws_s3_bucket_server_side_encryption_configuration" "for_partial_bucket" {
  skip = true
  attrs = {
    bucket = "plan-time-bucket"
    rule = [{
      apply_server_side_encryption_by_default = [{
        sse_algorithm = "aws:kms"
        # kms_master_key_id intentionally omitted — treated as unknown
      }]
    }]
  }
  meta = { provider_type = "aws" }
}

# Minimal encryption config: only the required `bucket` attr is present;
# the entire rule structure is unknown. Exercises the worst-case unknown path
# through core::valuetostring.
resource "aws_s3_bucket_server_side_encryption_configuration" "for_minimal_bucket" {
  skip = true
  attrs = {
    bucket = "minimal-bucket"
    # rule intentionally omitted — treated as unknown
  }
  meta = { provider_type = "aws" }
}

# =============================================================================
# Test cases
# =============================================================================

# PASS — fully-known config exists. core::valuetostring(configs) serialises
# the entire object, including nested rule/sse_algorithm attrs.
resource "aws_s3_bucket" "known_attrs_pass" {
  expect_failure = false
  attrs = {
    bucket = "my-bucket"
  }
  meta = { provider_type = "aws" }
}

# PASS — encryption config exists but has unknown leaves (kms_master_key_id).
# Verifies that core::valuetostring does not abort when an unknown leaf is
# encountered; it renders it as "(unknown)" and the policy still passes.
resource "aws_s3_bucket" "partially_unknown_config_pass" {
  expect_failure = false
  attrs = {
    bucket = "plan-time-bucket"
  }
  meta = { provider_type = "aws" }
}

# PASS — encryption config exists but most attrs are unknown (only bucket
# present in the config fixture). Exercises the mostly-unknown code path
# inside core::valuetostring.
resource "aws_s3_bucket" "mostly_unknown_config_pass" {
  expect_failure = false
  attrs = {
    bucket = "minimal-bucket"
  }
  meta = { provider_type = "aws" }
}

# FAIL — no matching aws_s3_bucket_server_side_encryption_configuration exists
# for this bucket. The policy condition (has_config) is false, so the enforce
# block should deny. core::valuetostring(configs) renders an empty list "[]"
# in the info_message without error.
resource "aws_s3_bucket" "no_encryption_config_fail" {
  expect_failure = true
  attrs = {
    bucket = "unprotected-bucket"
  }
  meta = { provider_type = "aws" }
}
