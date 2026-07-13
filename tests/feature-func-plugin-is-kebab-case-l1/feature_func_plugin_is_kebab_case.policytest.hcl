# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

policytest {
  targets = ["feature_func_plugin_is_kebab_case.policy.hcl"]
  plugins {
    sample = { source = "./plugin/plugin_binary" }
  }
}

resource "aws_security_group" "pass_simple" {
  expect_failure = false
  attrs = { name = "my-app-sg" }
  meta  = { provider_type = "aws" }
}

resource "aws_security_group" "pass_with_digits" {
  expect_failure = false
  attrs = { name = "tier2-frontend-sg" }
  meta  = { provider_type = "aws" }
}

resource "aws_security_group" "fail_snake_case" {
  expect_failure = true
  attrs = { name = "my_app_sg" }
  meta  = { provider_type = "aws" }
}

resource "aws_security_group" "fail_pascal_case" {
  expect_failure = true
  attrs = { name = "MyAppSG" }
  meta  = { provider_type = "aws" }
}

resource "aws_security_group" "fail_leading_hyphen" {
  expect_failure = true
  attrs = { name = "-my-app-sg" }
  meta  = { provider_type = "aws" }
}

resource "aws_security_group" "fail_double_hyphen" {
  expect_failure = true
  attrs = { name = "my--app-sg" }
  meta  = { provider_type = "aws" }
}
