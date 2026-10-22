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

resource_policy "aws_dms_endpoint" "engine_filtered" {
  filter = attrs.engine_name == input.engine
  enforce {
    condition     = false
    error_message = "must not be evaluated: engine does not match input"
  }
}
