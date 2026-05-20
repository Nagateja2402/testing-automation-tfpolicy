
policytest {
  targets = ["skip_resource.policy.hcl"]
}

# skip=true: used as getresources target, not evaluated as its own test case
resource "aws_s3_bucket" "my-primary-bucket-logs" {
  skip = true
  attrs = {
    bucket = "my-primary-bucket-logs"
  }
}

resource "aws_s3_bucket" "pass_has_logs_partner" {
  expect_failure = false
  attrs = {
    bucket = "my-primary-bucket"
  }
}
