# Copyright (c) HashiCorp, Inc.
# `meta` has no address/name field (only type, provider_type, operation,
# module_path) — naming-convention checks must read a real provider
# attribute instead, e.g. the "Name" tag.

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}
resource_policy "aws_instance" "name_follows_convention" {
  locals {
    naming_pattern = "^(web|api|db|cache)-[a-z]+-[0-9]+$"
    resource_name  = core::try(attrs.tags.Name, "")
  }

  enforce {
    condition     = core::length(core::regexall(local.naming_pattern, local.resource_name)) > 0
    error_message = "Resource name '${local.resource_name}' must follow convention: {role}-{service}-{number}"
  }
}
