policytest {
  targets = ["basics_try_null_attrs.policy.hcl"]
}

resource "aws_s3_bucket" "no_kms" {
  expect_failure = true
  attrs = {
    bucket = "basics-try-null-attrs-blocks-q"
    bucket_prefix = null
  }
}
