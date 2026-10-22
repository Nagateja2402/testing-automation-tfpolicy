# provider-policy-alias-disallowed-blocks: provider_policy across aliases: alias in eu-west-1 fails
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }
provider "aws" {
  alias  = "west"
  region = "us-west-2"
}
provider "aws" {
  alias  = "eu"
  region = "eu-west-1"
}
resource "aws_s3_bucket" "q" { bucket = "provider-policy-alias-disallowed-b-q" }
resource "aws_s3_bucket" "w" {
  provider = aws.west
  bucket     = "provider-policy-alias-disallowed-b-w"
}
resource "aws_s3_bucket" "e" {
  provider = aws.eu
  bucket     = "provider-policy-alias-disallowed-b-e"
}
