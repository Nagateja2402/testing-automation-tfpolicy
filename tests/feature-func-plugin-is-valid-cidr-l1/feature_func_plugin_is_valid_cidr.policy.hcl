# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_func_plugin_is_valid_cidr
# Covers : plugin::sample::is_valid_cidr — bool-returning custom function
# =============================================================================

resource_policy "aws_security_group" "feature_func_plugin_is_valid_cidr" {
  locals {
    cidrs       = core::try(attrs.ingress[*].cidr, [])
    invalid     = [for c in local.cidrs : c if !plugin::sample::is_valid_cidr(c)]
  }

  enforce {
    condition     = core::length(local.invalid) == 0
    error_message = "ingress.cidr entries failed CIDR validation: ${core::join(", ", local.invalid)}"
  }
}
