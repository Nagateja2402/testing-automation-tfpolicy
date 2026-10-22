policytest {
  targets = ["s3.policy.hcl"]
}

resource "aws_s3_bucket" "prod_bucket" {
  expect_failure = false
  attrs = {
    bucket = "basics-cross-file-inputs-helpers-e-b-nagateja"
    tags = { env = "prod" }
  }
}

resource "aws_s3_bucket" "dev_bucket" {
  expect_failure = true
  attrs = {
    bucket = "basics-cross-file-inputs-helpers-e-b2-nagateja"
    tags = { env = "dev" }
  }
}
