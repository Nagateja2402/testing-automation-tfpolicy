# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_expr_for_map
# Covers : for-expression producing a map
# =============================================================================

resource_policy "aws_instance" "feature_expr_for_map" {
  locals {
    tag_map = { for k, v in core::try(attrs.tags, {}) : k => v if v != "" }
  }
  enforce {
    condition     = core::contains(core::keys(local.tag_map), "owner")
    error_message = "owner tag required"
  }
}
