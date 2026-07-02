# Copyright (c) HashiCorp, Inc.

policy {}

resource_policy "aws_instance" "name_follows_convention" {
  locals {
    naming_pattern = "^(web|api|db|cache)-[a-z]+-[0-9]+$"
  }

  enforce {
    condition     = core::length(core::regexall(local.naming_pattern, meta.name)) > 0
    error_message = "Resource name '${meta.name}' must follow convention: {role}-{service}-{number}"
  }
}
