# basics-getdatasource-missing-errors: core::getdatasource of a nonexistent aws_s3_bucket surfaces a clear data-source lookup error
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}
provider "aws" { region = "us-east-1" }
resource "aws_s3_bucket" "q" {
  bucket = "basics-getdatasource-missing-error-q"
}
