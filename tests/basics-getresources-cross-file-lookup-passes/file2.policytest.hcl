policytest {
  targets = ["file2.policy.hcl"]
}

resource "aws_s3_bucket_logging" "ct" {
  skip = true
  attrs = {
    bucket = "basics-getresources-cross-file-loo-ct-nagateja"
    target_bucket = "basics-getresources-cross-file-loo-logs-nagateja"
    target_prefix = "log/"
  }
}

resource "aws_cloudtrail" "t" {
  expect_failure = false
  attrs = {
    name = "basics-getresources-cross-file-loo-trail"
    s3_bucket_name = "basics-getresources-cross-file-loo-ct-nagateja"
  }
}
