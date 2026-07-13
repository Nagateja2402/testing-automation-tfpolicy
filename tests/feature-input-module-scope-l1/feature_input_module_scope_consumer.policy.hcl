# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_input_module_scope_consumer
# Covers : referencing inputs declared in *another* file of the same policy
#          module. Proves cross-file `input.<name>` resolution.
# Pair   : feature_input_module_scope_definer.policy.hcl
# Refs   : input.module_required_prefix, input.module_max_instance_count,
#          input.module_required_tags  (defined in the definer file)
# =============================================================================

resource_policy "aws_s3_bucket" "feature_input_module_scope_prefix" {
  enforcement_level = "advisory"
  enforce {
    condition     = core::length(core::regexall("^${input.module_required_prefix}", core::try(attrs.bucket, ""))) > 0
    error_message = "bucket '${core::try(attrs.bucket, "<unset>")}' must start with input-level prefix '${input.module_required_prefix}'"
  }
}

resource_policy "aws_instance" "feature_input_module_scope_tag_keys" {
  enforcement_level = "advisory"
  locals {
    tag_keys = core::keys(core::try(attrs.tags, {}))
    missing  = [for k in input.module_required_tags : k if !core::contains(local.tag_keys, k)]
  }

  enforce {
    condition     = core::length(local.missing) == 0
    error_message = "missing required tag keys (from module input): ${core::join(", ", local.missing)}"
  }
}

resource_policy "aws_autoscaling_group" "feature_input_module_scope_max_count" {
  enforce {
    condition     = core::try(attrs.desired_capacity, 0) <= input.module_max_instance_count
    error_message = "desired_capacity ${core::try(attrs.desired_capacity, 0)} exceeds module input cap ${input.module_max_instance_count}"
  }
}
