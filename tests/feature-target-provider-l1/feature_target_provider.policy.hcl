# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_target_provider
# Covers : provider_policy targets a provider block
# =============================================================================

provider_policy "aws" "feature_target_provider" {
  enforce {
    condition    = meta.type == "aws"
    info_message = "provider target selected"
  }
}
