# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

module_policy "*" "addr_index" {
  locals {
    allowed = ["module.s3_match", "module.s3_other"]
    matches = [for i in core::range(core::length(local.allowed)) : i if local.allowed[i] == meta.address]
    idx     = core::length(local.matches) > 0 ? local.matches[0] : -1
  }
  enforce {
    condition     = local.idx >= 0
    error_message = "module ${meta.address} index ${local.idx}; not in allowed list"
  }
}
