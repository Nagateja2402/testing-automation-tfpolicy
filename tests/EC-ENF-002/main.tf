# EC-ENF-002: info_message on passing condition — should not block.
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
  bucket = "ec-enf-002-bucket"
  tags = {
    Environment = "dev"
  }
}
