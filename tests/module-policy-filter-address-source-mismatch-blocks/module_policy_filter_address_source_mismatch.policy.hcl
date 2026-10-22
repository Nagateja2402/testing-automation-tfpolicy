# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

module_policy "*" "src_bad" {
  filter = meta.address == "module.s3_match"
  enforce {
    condition     = meta.source == "./modules/other"
    error_message = "module source must be ./modules/other"
  }
}
