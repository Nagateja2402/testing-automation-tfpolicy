# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_toplevel_locals_block
# Covers : file-scope locals visible to every rule
# =============================================================================

locals {
  required_prefix = "prod-"
}

resource_policy "aws_s3_bucket" "toplevel_locals_block" {
  enforce {
    condition     = plugin::sample::trim(core::try(attrs.bucket, ""), local.required_prefix) != core::try(attrs.bucket, "")
    error_message = "bucket name must start with ${local.required_prefix}"
  }
}
