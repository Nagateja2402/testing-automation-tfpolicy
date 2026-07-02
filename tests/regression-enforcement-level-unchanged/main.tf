# REG-BIN-009: Enforcement levels regression — advisory + mandatory.
# Bucket with env tag but no versioning:
#   advisory_check (versioning) → Warning (advisory, not blocked)
#   mandatory_check (env tag) → PASS
# Overall: PASS (advisory warning does not block)
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
  bucket = "reg-bin-009-bucket"
  # versioning_enabled not set → advisory_check warns (not blocked)
  # Environment tag present → mandatory_check passes
  tags = {
    Environment = "dev"
  }
}
