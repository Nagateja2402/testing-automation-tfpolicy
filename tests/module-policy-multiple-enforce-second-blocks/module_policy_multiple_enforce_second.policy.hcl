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
    condition     = meta.source == "./modules/other"
    error_message = "enforce2: module source must be ./modules/other"
  }
}
