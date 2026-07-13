# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_func_plugin_is_kebab_case
# Covers : plugin::sample::is_kebab_case — regex-based bool function
# =============================================================================

resource_policy "aws_security_group" "feature_func_plugin_is_kebab_case" {
  locals {
    name = core::try(attrs.name, "")
  }

  enforce {
    condition     = local.name != "" && plugin::sample::is_kebab_case(local.name)
    error_message = "security group name '${local.name}' must be kebab-case (e.g. 'my-app-sg')"
  }
}
