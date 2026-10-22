# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

module_policy "*" "combined" {
  enforce {
    condition     = meta.source == "./modules/s3" && core::regex_match(meta.address, "^module\\.s3_") && meta.version == null
    error_message = "module ${meta.address} must use ./modules/s3, be named s3_*, and have no version"
  }
}
