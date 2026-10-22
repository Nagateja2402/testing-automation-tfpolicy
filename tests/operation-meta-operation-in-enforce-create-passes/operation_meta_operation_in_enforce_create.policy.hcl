# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_s3_bucket" "meta_op_enforce" {
  enforce {
    condition     = meta.operation == "create"
    error_message = "METAOP not create: ${meta.operation}"
  }
}
