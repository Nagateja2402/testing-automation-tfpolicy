# basics-getresources-cross-file-lookup-passes: core::getresources lookup for aws_s3_bucket_logging from a policy in another file passes for cloudtrail bucket
# tfp plan: PASS
# tfp apply: N/A
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" { region = "us-east-1" }
resource "aws_s3_bucket" "ct" { bucket = "basics-getresources-cross-file-loo-ct-nagateja" }
resource "aws_s3_bucket" "logs" { bucket = "basics-getresources-cross-file-loo-logs-nagateja" }
resource "aws_s3_bucket_logging" "ct" {
  bucket        = "basics-getresources-cross-file-loo-ct-nagateja"
  target_bucket = "basics-getresources-cross-file-loo-logs-nagateja"
  target_prefix = "log/"
}
resource "aws_cloudtrail" "t" {
  name           = "basics-getresources-cross-file-loo-trail"
  s3_bucket_name = "basics-getresources-cross-file-loo-ct-nagateja"
}
