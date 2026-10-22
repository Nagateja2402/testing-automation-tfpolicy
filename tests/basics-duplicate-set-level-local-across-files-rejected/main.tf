# basics-duplicate-set-level-local-across-files-rejected: same set-level local defined in two policy files is a setup error (Duplicate local expression)
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }

resource "aws_s3_bucket" "q" { bucket = "basics-duplicate-set-level-local-a-q" }
