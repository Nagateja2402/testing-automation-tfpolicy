# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_s3_bucket" "both_messages" {
  enforce {
    condition     = false
    error_message = "ERROR_MSG_TEXT: bucket is not compliant"
    info_message  = "INFO_MSG_TEXT: remediation guidance here"
  }
}
