# GR-DEP-012: getresources on nonexistent resource type — always returns empty
# Plan: FAIL, Apply: FAIL

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
  bucket        = "gr-dep-012-main-bucket-xyz"
  force_destroy = true
}
