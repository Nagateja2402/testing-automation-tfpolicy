# Copyright (c) HashiCorp, Inc.

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}
input "engine" {
  type    = string
  default = "mysql"
}

resource_policy "aws_dms_endpoint" "validate_engine_from_input" {
  filter = attrs.engine_name == input.engine

  enforce {
    condition     = attrs.engine_name == "mysql"
    error_message = "Engine must be mysql (input default: ${input.engine})"
  }
}
