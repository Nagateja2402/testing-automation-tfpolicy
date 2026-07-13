# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_func_core_semverconstraint
# Covers : core::semverconstraint tests semver against a constraint
# =============================================================================

resource_policy "aws_s3_bucket" "feature_func_core_semverconstraint" {
  enforce {
    condition    = core::semverconstraint("1.2.3", ">= 1.0.0")
    info_message = "core::semverconstraint executed"
  }
}
