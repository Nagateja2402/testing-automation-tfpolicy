# REG-BIN-001: Pre-existing passing policy must still pass on new binary.
# S3 bucket with Environment tag → PASS.
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
  bucket = "reg-bin-001-bucket"
  tags = {
    Environment = "dev"
  }
}
