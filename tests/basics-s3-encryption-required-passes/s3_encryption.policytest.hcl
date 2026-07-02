
policytest {
  targets = ["s3_encryption.policy.hcl"]
}

resource "aws_s3_bucket" "tagged_bucket_passes" {
  expect_failure = false
  attrs = {
    bucket = "compliant-bucket"
    tags = {
      Environment = "production"
    }
  }
}

resource "aws_s3_bucket" "untagged_bucket_fails" {
  expect_failure = true
  attrs = {
    bucket = "untagged-bucket"
  }
}
