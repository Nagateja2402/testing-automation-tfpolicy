# GR-DEP-002: CloudTrail logs to private S3 bucket — happy path
# s3_bucket_name is config-known so getresources filter resolves at plan time
# tfp plan: PASS, tfp apply: PASS

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "trail_bucket" {
  bucket        = "gr-dep-002-cloudtrail-bucket-unique-xyz"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "trail_bucket" {
  bucket = aws_s3_bucket.trail_bucket.id
  rule { object_ownership = "BucketOwnerPreferred" }
}

resource "aws_s3_bucket_acl" "trail_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.trail_bucket]
  bucket     = aws_s3_bucket.trail_bucket.id
  acl        = "private"
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_policy" "trail" {
  bucket = aws_s3_bucket.trail_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AWSCloudTrailAclCheck"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:GetBucketAcl"
        Resource  = aws_s3_bucket.trail_bucket.arn
      },
      {
        Sid       = "AWSCloudTrailWrite"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.trail_bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = { StringEquals = { "s3:x-amz-acl" = "bucket-owner-full-control" } }
      }
    ]
  })
}

resource "aws_cloudtrail" "main" {
  name                          = "gr-dep-002-trail"
  s3_bucket_name                = aws_s3_bucket.trail_bucket.bucket
  include_global_service_events = false
  # depends_on includes aws_s3_bucket_acl so its planned state is available
  # in ChangesSync when this resource's policy evaluates via getresources.
  depends_on = [aws_s3_bucket_policy.trail, aws_s3_bucket_acl.trail_bucket]
}
