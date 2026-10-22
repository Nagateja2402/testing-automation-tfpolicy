# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

module_policy "*" "try_version" {
  enforce {
    condition     = core::try(core::semverconstraint(meta.version, ">= 1.0.0"), false)
    error_message = "module version must be present and >= 1.0.0"
  }
}
