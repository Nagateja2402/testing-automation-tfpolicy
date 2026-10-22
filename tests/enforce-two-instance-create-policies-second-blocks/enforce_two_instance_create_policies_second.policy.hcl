# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_instance" "first_passing" {
  operations = ["create"]
  enforce {
    condition     = true
    error_message = "FIRST_POLICY_FAILURE_MESSAGE"
  }
}

resource_policy "aws_instance" "second_failing" {
  operations = ["create"]
  enforce {
    condition     = false
    error_message = "SECOND_POLICY_FAILURE_MESSAGE"
  }
}
