# Copyright (c) HashiCorp, Inc.
# Minimum required module version: major version must be 2 or higher.
# Checks that version is non-empty and does not start with "0." or "1.".

policy {}

module_policy "*" "must_meet_minimum_version" {
  locals {
    version = core::try(meta.version, "")
  }

  enforce {
    condition     = local.version != ""
    error_message = "Module version must be pinned"
  }

  enforce {
    condition     = !core::startswith(local.version, "0.") && !core::startswith(local.version, "1.")
    error_message = "Module version must be at least 2.0.0 (major version >= 2)"
  }
}
