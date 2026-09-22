
policytest {
  targets = ["regex_bucket_name.policy.hcl"]
}

resource "aws_s3_bucket" "valid_name_passes" {
  expect_failure = false
  attrs = {
    bucket = "my-valid-data-bucket"
  }
}

resource "aws_s3_bucket" "uppercase_name_fails" {
  expect_failure = true
  attrs = {
    bucket = "My_Invalid_Bucket"
  }
}

resource "aws_s3_bucket" "empty_name_fails" {
  expect_failure = true
  attrs = {
    force_destroy = false
  }
}
