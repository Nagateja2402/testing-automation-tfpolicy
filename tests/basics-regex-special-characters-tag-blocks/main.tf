# basics-regex-special-characters-tag-blocks: regex name-tag convention fails deterministically on unicode/quotes/<>&/backslash tag value; message renders intact
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}
provider "aws" { region = "us-east-1" }
resource "aws_s3_bucket" "q" {
  bucket = "basics-regex-special-characters-ta-q"
  tags = { Name = "caf\u00e9 \"q\" <x>&'日本 \\d" }
}
