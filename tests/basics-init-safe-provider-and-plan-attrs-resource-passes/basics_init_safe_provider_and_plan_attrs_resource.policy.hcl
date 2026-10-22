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

locals {
  want = "aws"
}

provider_policy "aws" "init_safe" {
  enforce {
    condition     = meta.type == local.want && input.allowed_type == "aws"
    error_message = "init-safe policy failed"
  }
}

resource_policy "aws_s3_bucket" "plan_attrs" {
  enforce {
    condition     = core::startswith(attrs.bucket, "basics-init-safe-provider-and-plan-")
    error_message = "plan-stage attrs policy failed"
  }
}
