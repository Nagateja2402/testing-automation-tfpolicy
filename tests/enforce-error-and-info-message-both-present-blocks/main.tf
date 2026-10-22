# enforce-error-and-info-message-both-present-blocks: enforce with both error_message and info_message on a failing condition: both emitted
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}
provider "aws" { region = "us-east-1" }

resource "aws_s3_bucket" "q" { bucket = "enforce-error-and-info-message-bot-q" }
