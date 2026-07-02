# basics-s3-encryption-required-blocks: S3 bucket missing the required Environment tag.
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
  bucket = "basics-s3-enc-required-block-bucket"
}
