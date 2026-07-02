
policytest {
  targets = ["regex_name_block.policy.hcl"]
}

resource "aws_s3_bucket" "prefixed_name_passes" {
  expect_failure = false
  attrs = {
    bucket = "data-analytics-store"
  }
}

resource "aws_s3_bucket" "no_prefix_fails" {
  expect_failure = true
  attrs = {
    bucket = "random-bucket-name"
  }
}
