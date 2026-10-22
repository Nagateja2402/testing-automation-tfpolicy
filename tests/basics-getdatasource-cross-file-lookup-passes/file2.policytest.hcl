policytest {
  targets = ["file2.policy.hcl"]
}

data "aws_region" "current" {
  attrs = {
    name = "us-east-1"
    region = "us-east-1"
  }
}

resource "aws_s3_bucket" "q" {
  expect_failure = false
  attrs = {
    bucket = "basics-getdatasource-cross-file-lo-q"
  }
}
