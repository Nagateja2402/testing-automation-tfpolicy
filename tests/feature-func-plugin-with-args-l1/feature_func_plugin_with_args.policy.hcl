# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_func_plugin_with_args
# Covers : plugin function accepting multiple arguments
# =============================================================================

resource_policy "aws_s3_bucket" "feature_func_plugin_with_args" {
  enforce {
    condition    = plugin::sample::trim("prod-foo", "prod-") == "foo"
    info_message = "plugin trim accepted two args"
  }
}
