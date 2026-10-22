policytest {
  targets = ["basics_for_each_one_instance.policy.hcl"]
}

resource "aws_s3_bucket" "a" {
  expect_failure = false
  attrs = {
    bucket = "basics-for-each-one-instance-block-a"
  }
}

resource "aws_s3_bucket" "bad" {
  expect_failure = true
  attrs = {
    bucket = "bad-bucket"
  }
}

resource "aws_s3_bucket" "c" {
  expect_failure = false
  attrs = {
    bucket = "basics-for-each-one-instance-block-c"
  }
}
