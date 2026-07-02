# basics-provider-region-allowed-passes: provider region us-east-1 is allowed.
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
  bucket = "basics-provider-region-pass-bucket"
}
