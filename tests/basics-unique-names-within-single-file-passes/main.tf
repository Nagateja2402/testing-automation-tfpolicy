# basics-unique-names-within-single-file-passes: unique inputs and policy names within a single file are valid; both s3 policies evaluate independently
# tfp plan: PASS
# tfp apply: PASS
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}
provider "aws" { region = "us-east-1" }
resource "aws_s3_bucket" "b" {
  bucket = "basics-unique-names-within-single-b-nagateja"
  tags   = { a = "x", b = "y" }
}
