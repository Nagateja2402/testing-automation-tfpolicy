# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_target_resource_wildcard
# Covers : resource_policy "*" matches every resource type
# =============================================================================

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "*" "feature_target_resource_wildcard" {
  enforce {
    condition    = true
    info_message = "wildcard target matched ${meta.provider_type}"
  }
}
