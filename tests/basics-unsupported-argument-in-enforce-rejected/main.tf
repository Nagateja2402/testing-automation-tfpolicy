# basics-unsupported-argument-in-enforce-rejected: unsupported argument in enforce block is a clear setup error (Unsupported argument), not a generic failure
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }

resource "aws_s3_bucket" "q" { bucket = "basics-unsupported-argument-in-enf-q" }
