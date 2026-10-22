# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

module_policy "*" "ternary" {
  enforce {
    condition     = meta.address == "module.q" ? meta.source == "./modules/q" : true
    error_message = "module ${meta.address} source must be ./modules/q"
  }
}
