# operations-value-case-sensitive-rejected: operations=["Create"] (capitalised) is a setup error: Invalid operation, must be create/update/delete/no-op
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }
resource "aws_s3_bucket" "q" { bucket = "operations-value-case-sensitive-re-q" }
