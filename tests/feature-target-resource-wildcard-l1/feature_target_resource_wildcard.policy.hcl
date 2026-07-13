# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_target_resource_wildcard
# Covers : resource_policy "*" matches every resource type
# =============================================================================

resource_policy "*" "feature_target_resource_wildcard" {
  enforce {
    condition    = true
    info_message = "wildcard target matched ${meta.provider_type}"
  }
}
