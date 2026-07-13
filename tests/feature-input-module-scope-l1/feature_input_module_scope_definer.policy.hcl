# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_input_module_scope_definer
# Covers : module-level (cross-file) `input "..." {}` declaration.
#          This file declares no policy. It only contributes top-level inputs
#          to the policy module so other files in the same --policies directory
#          can reference them via `input.<name>`.
# Pair   : feature_input_module_scope_consumer.policy.hcl
# =============================================================================

input "module_required_prefix" {
  type    = string
  default = "regression-"
}

input "module_max_instance_count" {
  type    = number
  default = 5
}

input "module_required_tags" {
  type    = list(string)
  default = ["owner", "environment"]
}
