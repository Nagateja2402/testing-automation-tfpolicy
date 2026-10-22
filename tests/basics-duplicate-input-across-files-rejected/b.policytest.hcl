policytest {
  targets = ["b.policy.hcl"]
}

resource "aws_s3_bucket" "q" {
  expect_failure = false
  attrs = {
    bucket = "basics-duplicate-input-across-file-q"
  }
}
