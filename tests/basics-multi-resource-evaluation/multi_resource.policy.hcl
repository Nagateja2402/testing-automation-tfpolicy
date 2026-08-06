# Copyright (c) HashiCorp, Inc.

policy {}

resource_policy "aws_instance" "no_t2_micro" {
  enforce {
    condition     = core::try(attrs.instance_type, "") != "t2.micro"
    error_message = "Instance type t2.micro is not allowed"
  }
}
