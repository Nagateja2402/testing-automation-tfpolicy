# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_func_plugin_count_substring
# Covers : plugin::sample::count_substring — int-returning custom function
# =============================================================================

input "max_dots" {
  type    = number
  default = 3
}

resource_policy "aws_s3_bucket" "feature_func_plugin_count_substring" {
  locals {
    bucket    = core::try(attrs.bucket, "")
    dot_count = plugin::sample::count_substring(local.bucket, ".")
  }

  enforce {
    condition     = local.dot_count <= input.max_dots
    error_message = "bucket name '${local.bucket}' has ${local.dot_count} dots; limit is ${input.max_dots}"
  }
}
