# OP-ALL-E2E: create operation with ResourceName tag set — split
# create/update policy block passes; real plan+apply should PASS.

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
  bucket = "op-all-e2e-bucket"
  tags = {
    ResourceName = "op-all-e2e-bucket"
  }
}
