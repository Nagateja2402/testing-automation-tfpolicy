# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_local_module_scope_definer
# Covers : module-level (cross-file) `locals {}` declaration.
#          This file declares no policy. It only contributes top-level locals
#          to the policy module so other files in the same --policies directory
#          can reference them via `local.<name>`.
# Pair   : feature_local_module_scope_consumer.policy.hcl
# =============================================================================

locals {
  module_required_prefix = "regression-"
  module_max_name_length = 40
  module_allowed_regions = ["us-east-1", "us-west-2", "eu-west-1"]
}
