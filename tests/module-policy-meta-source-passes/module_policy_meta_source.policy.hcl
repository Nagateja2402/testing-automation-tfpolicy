# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

module_policy "./modules/q" "meta_source" {
  enforce {
    condition     = meta.source == "./modules/q"
    info_message  = "meta.source is ${meta.source}"
    error_message = "unexpected module meta.source '${meta.source}'"
  }
}
