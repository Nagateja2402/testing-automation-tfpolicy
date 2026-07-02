# REG-BIN-004: Provider policy — must use approved region.
# AWS provider with us-east-1 (approved) → PASS.
# tfp plan: PASS
# tfp apply: PASS

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
  bucket = "reg-bin-004-bucket"
  tags = {}
}
