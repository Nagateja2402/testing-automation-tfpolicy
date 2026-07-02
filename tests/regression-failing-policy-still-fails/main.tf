# REG-BIN-002: Pre-existing failing policy must still fail on new binary.
# S3 bucket without Environment tag → FAIL.
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
  bucket = "reg-bin-002-bucket"
  tags = {}
}
