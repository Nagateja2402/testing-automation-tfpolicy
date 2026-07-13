# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_preplan_module_meta_source
# Covers : pre-plan-safe contract — module source must come from an approved
#          location. Reads only meta.source; no attrs touched.
# =============================================================================

input "approved_module_prefixes" {
  type    = list(string)
  default = ["./modules/", "registry.terraform.io/"]
}

module_policy "*" "feature_preplan_module_meta_source" {
  locals {
    source = core::try(meta.source, "")
    matches = [
      for prefix in input.approved_module_prefixes : prefix
      if core::length(core::regexall("^${prefix}", local.source)) > 0
    ]
  }

  enforce {
    condition     = core::length(local.matches) > 0
    error_message = "module source '${local.source}' is not from an approved prefix (${core::join(", ", input.approved_module_prefixes)})"
  }
}
