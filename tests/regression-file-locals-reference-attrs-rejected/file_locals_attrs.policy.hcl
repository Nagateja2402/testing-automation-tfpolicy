# Copyright (c) HashiCorp, Inc.
# REG-BIN: core v0.5.1 rejects file-level (policy-set-scope) `locals` that
# reference `attrs` or `prior_attrs` — those references are only valid
# inside a resource_policy/provider_policy/module_policy block's own
# `locals`. Loading this file must fail validation with a diagnostic
# pointing at the offending reference.

locals {
  bucket_name = attrs.bucket
}

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_s3_bucket" "file_locals_attrs" {
  enforce {
    condition     = local.bucket_name != ""
    error_message = "bucket name required"
  }
}
