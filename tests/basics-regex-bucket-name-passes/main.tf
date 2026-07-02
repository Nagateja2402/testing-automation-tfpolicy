# basics-regex-bucket-name-passes: bucket name starts with the required "data-" prefix.
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
  bucket = "data-basics-regex-pass-bucket"
}
