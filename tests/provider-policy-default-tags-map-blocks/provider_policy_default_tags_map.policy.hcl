# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

provider_policy "aws" "default_tags_map" {
  locals {
    tags = core::try(attrs.default_tags.tags, core::try(attrs.default_tags[0].tags, {}))
  }
  enforce {
    condition     = core::try(local.tags["Env"], "") == "prod"
    error_message = "provider default_tags must include Env=prod"
  }
}
