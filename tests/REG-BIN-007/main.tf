# REG-BIN-007: Operation inference unchanged on new binary.
# Create-only policy, new bucket with env tag → PASS.
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
  bucket = "reg-bin-007-bucket"
  tags = {
    Environment = "dev"
  }
}
