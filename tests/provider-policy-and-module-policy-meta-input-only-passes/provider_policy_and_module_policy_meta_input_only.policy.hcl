# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

input "allowed_type" {
  type    = string
  default = "aws"
}

provider_policy "aws" "meta_input_only" {
  enforce {
    condition     = meta.type == input.allowed_type
    error_message = "provider type mismatch"
    info_message  = "provider ${meta.type} version ${meta.version}"
  }
}

module_policy "./modules/q" "module_meta_input_only" {
  enforce {
    condition     = core::startswith(meta.source, "./modules/")
    error_message = "module source not local"
  }
}
