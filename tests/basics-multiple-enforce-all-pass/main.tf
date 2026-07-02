# basics-multiple-enforce-all-pass: both enforce blocks satisfied (name + Owner tag).
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
  bucket = "basics-multi-enforce-pass-bucket"
  tags = {
    Owner = "platform-team"
  }
}
