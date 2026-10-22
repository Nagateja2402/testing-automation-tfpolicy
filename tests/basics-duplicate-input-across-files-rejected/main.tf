# basics-duplicate-input-across-files-rejected: same input name defined in two policy files is a setup error (Duplicate input block)
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }

resource "aws_s3_bucket" "q" { bucket = "basics-duplicate-input-across-file-q" }
