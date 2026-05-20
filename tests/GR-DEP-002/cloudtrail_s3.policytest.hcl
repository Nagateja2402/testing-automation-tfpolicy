
policytest {
  targets = ["cloudtrail_s3.policy.hcl"]
}

resource "aws_s3_bucket" "trail_bucket" {
  skip = true
  attrs = {
    bucket = "my-cloudtrail-bucket"
  }
}

resource "aws_s3_bucket_acl" "trail_bucket" {
  skip = true
  attrs = {
    bucket = "my-cloudtrail-bucket"
    acl    = "private"
  }
}

resource "aws_cloudtrail" "pass_private_bucket" {
  expect_failure = false
  attrs = {
    s3_bucket_name = "my-cloudtrail-bucket"
    name           = "my-trail"
  }
}
