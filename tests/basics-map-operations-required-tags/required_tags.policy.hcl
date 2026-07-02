# Copyright (c) HashiCorp, Inc.

policy {}

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
