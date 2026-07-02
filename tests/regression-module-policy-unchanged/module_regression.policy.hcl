# Copyright (c) HashiCorp, Inc.
# REG-BIN-005: Module policy unaffected by binary change.

policy {}

module_policy "*" "must_use_approved_source" {
  locals {
    approved_sources = ["./modules/vpc", "./modules/s3"]
    source           = core::try(meta.source, "")
  }

  enforce {
    condition     = core::contains(local.approved_sources, local.source)
    error_message = "Module must be from approved source list"
  }
}
