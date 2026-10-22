# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

input "expected_source" {
  type    = string
  default = "./modules/other"
}

module_policy "*" "input_src" {
  filter = meta.address == "module.s3_match"
  enforce {
    condition     = meta.source == input.expected_source
    error_message = "module source ${meta.source} must equal input.expected_source (${input.expected_source})"
  }
}
