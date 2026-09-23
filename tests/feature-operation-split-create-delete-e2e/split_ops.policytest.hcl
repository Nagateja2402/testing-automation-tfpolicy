policytest {
  targets = ["split_ops.policy.hcl"]
}

resource "aws_s3_bucket" "create_passes" {
  expect_failure = false
  meta = { operation = "create" }
  attrs = {
    bucket = "split-ops-bucket"
    tags = {
      ResourceName = "split-ops-bucket"
    }
  }
}
