# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_func_plugin_sha256_hex
# Covers : plugin::sample::sha256_hex — string→string deterministic function
# =============================================================================

resource_policy "aws_s3_bucket" "feature_func_plugin_sha256_hex" {
  locals {
    bucket = core::try(attrs.bucket, "")
    digest = plugin::sample::sha256_hex(local.bucket)
    # Round-trip: hashing twice gives a stable 64-char hex string both times
    twice  = plugin::sample::sha256_hex(local.bucket)
  }

  enforce {
    condition     = local.digest == local.twice && local.digest != ""
    error_message = "sha256_hex(${local.bucket}) was non-deterministic or wrong length: ${local.digest}"
  }
}
