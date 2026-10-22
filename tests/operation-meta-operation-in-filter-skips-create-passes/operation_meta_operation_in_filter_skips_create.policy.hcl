# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_s3_bucket" "meta_op_filter" {
  filter = meta.operation == "delete"
  enforce {
    condition     = false
    error_message = "FILTERCHK should be skipped"
  }
}
