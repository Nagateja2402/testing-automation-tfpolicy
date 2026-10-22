# basics-empty-and-null-tags-map-blocks: resource_policy on empty {} and null tags map: no crash, Condition not met with clear message for both
# tfp plan: FAIL
# tfp apply: FAIL
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }
resource "aws_s3_bucket" "empty" {
  bucket = "basics-empty-and-null-tags-map-blo-empty"
  tags = {}
}
resource "aws_s3_bucket" "nulltags" {
  bucket = "basics-empty-and-null-tags-map-blo-null"
}
