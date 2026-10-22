# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_dms_endpoint" "dms_engine" {
  enforce {
    condition     = core::contains(["mysql", "postgres", "mongodb"], core::try(attrs.engine_name, ""))
    error_message = "condition failed: engine_name must be mysql/postgres/mongodb"
  }
}
resource_policy "aws_dms_endpoint" "dms_endpoint_id" {
  enforce {
    condition     = core::try(attrs.endpoint_id, "") != ""
    error_message = "condition failed: endpoint_id must be set"
  }
}
resource_policy "aws_dms_endpoint" "dms_ssl_mode" {
  enforce {
    condition     = core::contains(["require", "verify-ca", "verify-full"], core::try(attrs.ssl_mode, ""))
    error_message = "condition failed: ssl_mode must be require/verify-ca/verify-full"
  }
}
