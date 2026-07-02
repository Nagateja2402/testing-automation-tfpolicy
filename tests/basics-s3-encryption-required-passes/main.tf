# basics-s3-encryption-required-passes: compliant S3 bucket with Environment tag.
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
  bucket = "basics-s3-enc-required-pass-bucket"
  tags = {
    Environment = "production"
  }
}
