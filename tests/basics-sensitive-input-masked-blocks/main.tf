# basics-sensitive-input-masked-blocks: sensitive input used in condition and error_message: policy fails and secret is rendered as (sensitive value)
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}
provider "aws" { region = "us-east-1" }
resource "aws_s3_bucket" "q" {
  bucket = "basics-sensitive-input-masked-bloc-q"
  tags = { Token = "different" }
}
