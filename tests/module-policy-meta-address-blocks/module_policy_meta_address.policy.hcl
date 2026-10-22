# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

module_policy "./modules/s3" "module_meta_address" {
  enforcement_level = "mandatory"
  enforce {
    condition     = meta.address == "module.expected_other"
    error_message = "module meta.address '${meta.address}' (source ${meta.source}) does not match required module.expected_other"
  }
}
