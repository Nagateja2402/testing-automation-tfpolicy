# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

module_policy "./modules/q" "multi_enforce" {
  enforce {
    condition     = meta.source == "./modules/q"
    error_message = "enforce1: module source must be ./modules/q"
  }
  enforce {
    condition     = core::length(core::regexall("^\\./modules/", meta.source)) > 0
    error_message = "enforce2: module must be local under ./modules/"
  }
}
