
policytest {
  targets = ["getresources_empty_filter.policy.hcl"]
}

resource "aws_s3_bucket" "bucket_one" {
  skip = true
  attrs = {
    bucket = "bucket-one"
  }
}

resource "aws_s3_bucket" "bucket_two" {
  skip = true
  attrs = {
    bucket = "bucket-two"
  }
}

resource "aws_s3_bucket" "bucket_three" {
  skip = true
  attrs = {
    bucket = "bucket-three"
  }
}

resource "aws_s3_bucket" "pass_buckets_exist" {
  expect_failure = false
  attrs = {
    bucket = "my-primary-bucket"
  }
}
