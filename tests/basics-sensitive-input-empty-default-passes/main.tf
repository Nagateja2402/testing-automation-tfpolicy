# basics-sensitive-input-empty-default-passes: sensitive input with empty-string default evaluates correctly (no crash)
# tfp plan: PASS
# tfp apply: PASS
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}
provider "aws" { region = "us-east-1" }
resource "aws_s3_bucket" "q" {
  bucket = "basics-sensitive-input-empty-defau-q"
}
