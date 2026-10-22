# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

module_policy "./modules/q" "no_bad" {
  enforce {
    condition     = meta.address != "module.q_bad"
    error_message = "module ${meta.address} not allowed"
  }
}
