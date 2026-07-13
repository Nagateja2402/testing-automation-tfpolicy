# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test-framework-only feature: plugin functions called INSIDE a policytest file.
#
# tfpolicy merges plugin functions into the test-file eval context, so any
# `plugin::<name>::<fn>(...)` call is legal inside `locals`, `inputs`, or
# directly in a resource/data/module `attrs` value. This lets test fixtures
# derive their values from the same plugin functions the policies use, instead
# of hand-crafting them.
#
# Targets the shared trivial policy so the focus stays on the test feature.
# =============================================================================

policytest {
  targets = ["feature_target_resource.policy.hcl"]
  plugins {
    sample = { source = "./plugin/plugin_binary" }
  }
}

# NB: function calls (plugin or core) are NOT permitted inside test-file
# `locals` or `inputs` blocks — those evaluate before plugins are wired into
# the eval context. Plugin calls are valid only inside resource/provider/
# module/data `attrs` and `meta` values. See test/test.go RunTestFile order:
# locals → inputs → plugins-merge → data → cross-resource → run cases.

# (a) plugin call inside a resource's `attrs` map — the headline of this feature
resource "aws_s3_bucket" "pass_echo_in_attrs" {
  expect_failure = false
  attrs = {
    bucket = plugin::sample::echo("derived-via-plugin")
  }
  meta = { provider_type = "aws" }
}

# (b) plugin calls in two separate attrs (HCL string interpolation doesn't
#     accept nested quoted strings inside `${...}`, so we keep the calls
#     unwrapped rather than embedding them in an interpolation).
resource "aws_s3_bucket" "pass_trim_call" {
  expect_failure = false
  attrs = {
    bucket = plugin::sample::trim("regression-x", "")
  }
  meta = { provider_type = "aws" }
}

resource "aws_s3_bucket" "pass_hash_call" {
  expect_failure = false
  attrs = {
    bucket = plugin::sample::sha256_hex("seed")
  }
  meta = { provider_type = "aws" }
}

# (c) plugin call producing a value inside a deeply nested attr
resource "aws_security_group" "pass_cidr_check" {
  expect_failure = false
  attrs = {
    name    = "regression-sg"
    ingress = [
      { cidr = plugin::sample::echo("10.0.0.0/8") },
    ]
  }
  meta = { provider_type = "aws" }
}
