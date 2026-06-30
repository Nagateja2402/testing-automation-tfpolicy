# REG-BIN-010: Large policy file — 10 tag checks, all tags present → PASS.
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
  bucket = "reg-bin-010-bucket"
  tags = {
    Tag01 = "a"
    Tag02 = "b"
    Tag03 = "c"
    Tag04 = "d"
    Tag05 = "e"
    Tag06 = "f"
    Tag07 = "g"
    Tag08 = "h"
    Tag09 = "i"
    Tag10 = "j"
  }
}
