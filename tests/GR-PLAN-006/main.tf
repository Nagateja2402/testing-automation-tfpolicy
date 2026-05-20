# GR-PLAN-006: getresources returns no matches at plan or apply
# bucket name is config-known; companion bucket deliberately absent
# Empty result is deterministic → FAIL at both stages

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
  bucket        = "gr-plan-006-main-bucket-xyz"
  force_destroy = true
}

# Intentionally no companion bucket declared
