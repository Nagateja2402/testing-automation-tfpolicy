# Copyright (c) HashiCorp, Inc.

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}
resource_policy "aws_instance" "prod_requires_larger_type" {
  locals {
    instance_type = core::try(attrs.instance_type, "")
    is_production = core::try(attrs.tags.environment, "") == "production"
    required_type = local.is_production ? "m5.xlarge" : "t3.medium"
    type_matches  = local.instance_type == local.required_type
  }

  enforce {
    condition     = local.instance_type != "" && local.type_matches
    error_message = "Instance type must be ${local.required_type} for ${local.is_production ? "production" : "non-production"}"
  }
}
