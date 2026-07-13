# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_preplan_provider_meta_version
# Covers : pre-plan-safe contract — provider version constraint from meta only.
#          Uses core::semverconstraint on meta.version; no attrs touched.
# =============================================================================

provider_policy "aws" "feature_preplan_provider_meta_version" {
  locals {
    version = core::try(meta.version, "0.0.0")
  }

  enforce {
    condition     = core::semverconstraint(local.version, ">= 5.0.0")
    error_message = "aws provider version ${local.version} must be >= 5.0.0"
  }
}
