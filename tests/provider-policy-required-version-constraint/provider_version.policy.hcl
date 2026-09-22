# Copyright (c) HashiCorp, Inc.

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}
provider_policy "aws" "must_pin_version" {
  locals {
    version = core::try(meta.version, "")
  }

  enforce {
    condition     = local.version != ""
    error_message = "AWS provider version must be pinned"
  }
}
