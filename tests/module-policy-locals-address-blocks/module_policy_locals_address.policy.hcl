# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

locals {
  prefix = "module."
}

module_policy "*" "local_derived" {
  locals {
    expected = "${local.prefix}missing"
  }
  enforce {
    condition     = meta.address == local.expected
    error_message = "module address ${meta.address} != ${local.expected}"
  }
}
