# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

provider_policy "aws" "meta_type" {
  enforce {
    condition     = meta.type == "google"
    error_message = "provider meta.type is '${meta.type}', expected google"
  }
}
