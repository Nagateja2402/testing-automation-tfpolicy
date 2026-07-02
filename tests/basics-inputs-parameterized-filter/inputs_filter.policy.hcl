# Copyright (c) HashiCorp, Inc.

policy {}

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
