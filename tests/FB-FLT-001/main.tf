# FB-FLT-001: filter=false — non-production bucket skips enforce → PASS (even without versioning).
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
  bucket = "fb-flt-001-dev-bucket"
  # Environment = "dev" (not "production") → filter=false → enforce skipped → PASS
  tags = {
    Environment = "dev"
  }
}
