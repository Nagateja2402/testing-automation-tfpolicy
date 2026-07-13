# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_target_module
# Covers : module_policy targets a module instantiation
# =============================================================================

module_policy "./modules/*" "feature_target_module" {
  enforce {
    condition    = core::try(meta.source, "") != ""
    info_message = "module target selected"
  }
}
