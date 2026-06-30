# FB-FLT-002: filter=true — production bucket, enforce runs, versioning disabled → FAIL.
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
  bucket = "fb-flt-002-prod-bucket"
  # Environment = "production" → filter=true → enforce checks versioning → FAIL (no versioning)
  tags = {
    Environment = "production"
  }
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = "Suspended"
  }
}
