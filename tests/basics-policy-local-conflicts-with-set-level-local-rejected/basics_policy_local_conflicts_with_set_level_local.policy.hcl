# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

locals {
  name = "set-level"
}

resource_policy "aws_s3_bucket" "dup_local" {
  locals {
    name = "policy-scoped"
  }
  enforce {
    condition     = local.name == "policy-scoped"
    error_message = "name was ${local.name}"
  }
}
