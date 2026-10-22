# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_s3_bucket" "meta_missing" {
  filter = meta.operation == "create"
  locals {
    ws_tag = core::try(meta.workspace_tag, "<unset>")
  }
  enforce {
    condition     = local.ws_tag == "<unset>"
    error_message = "unexpected workspace tag ${local.ws_tag}"
  }
}
