# Copyright (c) HashiCorp, Inc.

policy {}

resource_policy "aws_dms_endpoint" "endpoint_fully_specified" {
  locals {
    allowed_engines = ["mysql", "postgres", "mongodb"]
    is_valid_engine = core::contains(local.allowed_engines, core::try(attrs.engine_name, ""))
    has_endpoint_id = core::try(attrs.endpoint_id, "") != ""
  }

  enforce {
    condition     = local.has_endpoint_id && local.is_valid_engine && core::try(attrs.ssl_mode, null) != null
    error_message = "DMS Endpoint must have endpoint_id, valid engine (${core::join(", ", local.allowed_engines)}), and ssl_mode"
  }
}
