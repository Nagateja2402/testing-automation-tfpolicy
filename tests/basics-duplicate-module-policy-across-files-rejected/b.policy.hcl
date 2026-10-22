# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

module_policy "./modules/q" "validation" {
  enforce {
    condition     = attrs.name != "x"
    error_message = "b: name not x"
  }
}
