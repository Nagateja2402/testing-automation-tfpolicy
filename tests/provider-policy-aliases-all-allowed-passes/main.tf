# provider-policy-aliases-all-allowed-passes: provider_policy across 3 aws provider configs (default/west/east2) all in allowed regions
# tfp plan: PASS
# tfp apply: PASS
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
  alias  = "east2"
  region = "us-east-2"
}
resource "aws_s3_bucket" "q" { bucket = "provider-policy-aliases-all-allowe-q" }
resource "aws_s3_bucket" "w" {
  provider = aws.west
  bucket     = "provider-policy-aliases-all-allowe-w"
}
resource "aws_s3_bucket" "e" {
  provider = aws.east2
  bucket     = "provider-policy-aliases-all-allowe-e"
}
