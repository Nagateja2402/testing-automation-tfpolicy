
policytest {
  targets = ["getresources_multi_filter.policy.hcl"]
}

resource "aws_s3_bucket" "private_bucket_us_east" {
  skip = true
  attrs = {
    bucket = "private-bucket-us-east"
    region = "us-east-1"
    acl    = "private"
  }
}

resource "aws_s3_bucket" "private_bucket_us_west" {
  skip = true
  attrs = {
    bucket = "private-bucket-us-west"
    region = "us-west-2"
    acl    = "private"
  }
}

resource "aws_s3_bucket" "pass_has_private_in_region" {
  expect_failure = false
  attrs = {
    bucket = "my-primary-bucket"
    region = "us-east-1"
  }
}
