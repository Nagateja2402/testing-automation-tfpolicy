# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_func_plugin_cidr_contains_ip
# Covers : plugin::sample::cidr_contains_ip — two-arg bool, network containment
# =============================================================================

input "private_supernet" {
  type    = string
  default = "10.0.0.0/8"
}

resource_policy "aws_instance" "feature_func_plugin_cidr_contains_ip" {
  locals {
    ip = core::try(attrs.private_ip, "")
  }

  enforce {
    condition     = local.ip == "" || plugin::sample::cidr_contains_ip(input.private_supernet, local.ip)
    error_message = "private_ip '${local.ip}' must live inside ${input.private_supernet}"
  }
}
