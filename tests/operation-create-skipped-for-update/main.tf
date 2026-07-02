# OP-CRE-003: Create-only policy NOT evaluated on update.
# In L2/L3, new resources are always "create" → policy IS evaluated.
# We provide env tag so it passes even though the L1 test verifies update-skip.
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
  bucket = "op-cre-003-bucket"
  tags = {
    Environment = "dev"
  }
}
