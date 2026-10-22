# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

module_policy "*" "name_regex" {
  enforce {
    condition     = core::regex_match(meta.address, "^module\\.[a-z]+$")
    error_message = "module address ${meta.address} must match ^module\\.[a-z]+$"
  }
}
