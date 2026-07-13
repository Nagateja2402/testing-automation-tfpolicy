# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_toplevel_plugin_block
# Covers : plugin {} block registers a custom function source
# =============================================================================

policy {
  plugins {
    sample = {
      source = "./plugin/plugin_binary"
    }
  }
}

resource_policy "aws_s3_bucket" "toplevel_plugin_block" {
  enforce {
    condition    = plugin::sample::echo(core::try(attrs.bucket, "")) == core::try(attrs.bucket, "")
    info_message = "plugin function reachable"
  }
}
