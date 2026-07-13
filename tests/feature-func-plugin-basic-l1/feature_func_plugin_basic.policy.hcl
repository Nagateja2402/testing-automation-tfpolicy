# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_func_plugin_basic
# Covers : plugin::<name>::<fn> calls a plugin-registered function
# =============================================================================

resource_policy "aws_s3_bucket" "feature_func_plugin_basic" {
  enforce {
    condition    = plugin::sample::echo("ping") == "ping"
    info_message = "plugin echo round-tripped"
  }
}
