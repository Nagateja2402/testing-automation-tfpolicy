
policytest {
  targets = ["filter_versioning.policy.hcl"]
}

resource "aws_s3_bucket" "prod_with_owner_passes" {
  expect_failure = false
  attrs = {
    bucket = "prod-bucket"
    tags = {
      Environment = "production"
      Owner       = "sre"
    }
  }
}

resource "aws_s3_bucket" "prod_without_owner_fails" {
  expect_failure = true
  attrs = {
    bucket = "prod-bucket"
    tags = {
      Environment = "production"
    }
  }
}

resource "aws_s3_bucket" "dev_skipped_by_filter" {
  expect_failure = false
  attrs = {
    bucket = "dev-bucket"
    tags = {
      Environment = "dev"
    }
  }
}
