# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

module_policy "./modules/q" "map_required_key" {
  enforce {
    condition     = core::try(attrs.tags["owner"], "") == "platform"
    error_message = "module input tags must contain owner=platform"
  }
}
