# basics-provider-region-disallowed-blocks: provider region ap-south-1 not in allowed list.
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
  region = "ap-south-1"
}

resource "aws_s3_bucket" "main" {
  bucket = "basics-provider-region-block-bucket"
}
