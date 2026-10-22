policytest {
  targets = ["basics_getdatasource_aws_region.policy.hcl"]
}

data "aws_region" "current" {
  attrs = {
    name = "us-east-1"
    region = "us-east-1"
  }
}

resource "aws_s3_bucket" "q" {
  expect_failure = true
  attrs = {
    bucket = "basics-getdatasource-aws-region-bl-q"
  }
}
