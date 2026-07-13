# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_local_module_scope_consumer
# Covers : referencing locals declared in *another* file of the same policy
#          module. Proves cross-file `local.<name>` resolution.
# Pair   : feature_local_module_scope_definer.policy.hcl
# Refs   : local.module_required_prefix, local.module_max_name_length,
#          local.module_allowed_regions  (defined in the definer file)
# =============================================================================

resource_policy "aws_s3_bucket" "feature_local_module_scope_prefix" {
  enforcement_level = "advisory"
  locals {
    bucket = core::try(attrs.bucket, "")
  }

  enforce {
    condition     = core::length(core::regexall("^${local.module_required_prefix}", local.bucket)) > 0
    error_message = "bucket '${local.bucket}' must start with module-level prefix '${local.module_required_prefix}'"
  }

  enforce {
    # length-bound check via regex anchor — core::length doesn't work on strings
    condition     = core::length(core::regexall("^.{0,${local.module_max_name_length}}$", local.bucket)) > 0
    error_message = "bucket '${local.bucket}' exceeds module-level length cap of ${local.module_max_name_length}"
  }
}

provider_policy "aws" "feature_local_module_scope_region" {
  enforce {
    condition     = core::contains(local.module_allowed_regions, core::try(attrs.region, ""))
    error_message = "provider region '${core::try(attrs.region, "<unset>")}' is not in module-level allowlist ${core::join(", ", local.module_allowed_regions)}"
  }
}
