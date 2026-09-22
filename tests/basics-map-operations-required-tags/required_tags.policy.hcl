# Copyright (c) HashiCorp, Inc.

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}
resource_policy "aws_instance" "required_tags" {
  locals {
    tags            = core::try(attrs.tags, {})
    name_tag        = core::try(local.tags.name, "")
    environment_tag = core::try(local.tags.environment, "")
  }

  enforce {
    condition     = local.name_tag != "" && local.environment_tag != ""
    error_message = "Instance must have both 'name' and 'environment' tags"
  }
}
