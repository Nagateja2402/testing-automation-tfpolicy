# basics-filter-production-versioning-blocks: production bucket missing Owner tag.
# filter=true (Environment=production) → enforce runs → Owner missing → FAIL.
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
  bucket = "basics-filter-prod-block-bucket"
  tags = {
    Environment = "production"
  }
}
