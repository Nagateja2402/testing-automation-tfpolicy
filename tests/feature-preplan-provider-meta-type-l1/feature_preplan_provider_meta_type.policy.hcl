# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_preplan_provider_meta_type
# Covers : pre-plan-safe contract — provider policy that reads ONLY meta.
#          Pre-plan-safe means: no `attrs.*` references. The engine rejects
#          attrs references as hard errors when invoked at pre-plan stage
#          (terraform-policy-core/policy/policy_opts.go).
# =============================================================================

input "allowed_provider_types" {
  type    = list(string)
  default = ["aws", "random"]
}

provider_policy "*" "feature_preplan_provider_meta_type" {
  enforce {
    condition     = core::contains(input.allowed_provider_types, core::try(meta.type, ""))
    error_message = "provider type '${core::try(meta.type, "<unset>")}' is not in the allowlist (${core::join(", ", input.allowed_provider_types)})"
  }
}
