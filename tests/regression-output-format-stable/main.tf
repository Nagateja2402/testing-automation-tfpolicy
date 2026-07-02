# REG-BIN-003: Output format unchanged across binary versions.
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
  bucket = "reg-bin-003-bucket"
  tags = {
    Environment = "staging"
  }
}
