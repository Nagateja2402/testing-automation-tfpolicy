# EC-ENF-003: error_message on failing condition.
# tfp plan: FAIL
# tfp apply: FAIL

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "main" {
  bucket = "ec-enf-003-bucket"
  # No Environment tag → condition fails, error_message shown
  tags = {}
}
