# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_preplan_module_meta_version
# Covers : pre-plan-safe contract — module version pinning from meta only.
# =============================================================================

module_policy "./modules/*" "feature_preplan_module_meta_version" {
  # Local modules legitimately have no version, so skip the constraint when
  # meta.version is unset/empty. The rule fires only on versioned modules.
  filter = core::try(meta.version, "") != ""

  locals {
    version = core::try(meta.version, "0.0.0")
  }

  enforce {
    condition     = core::semverconstraint(local.version, ">= 1.0.0")
    error_message = "module version ${local.version} must be >= 1.0.0"
  }
}
