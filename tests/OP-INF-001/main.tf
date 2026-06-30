# OP-INF-001: Operation inferred as "create" when only attrs provided.
# Create-only policy runs and passes (env tag present).
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
  bucket = "op-inf-001-bucket"
  tags = {
    Environment = "dev"
  }
}
