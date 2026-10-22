# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_ssm_parameter" "jsondecode_value" {
  locals {
    doc = core::jsondecode(attrs.value)
  }
  enforce {
    condition     = local.doc.enabled == true
    error_message = "doc.enabled must be true"
  }
}
