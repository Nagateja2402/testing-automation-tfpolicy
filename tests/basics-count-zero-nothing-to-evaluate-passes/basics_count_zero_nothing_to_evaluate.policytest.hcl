policytest {
  targets = ["basics_count_zero_nothing_to_evaluate.policy.hcl"]
}

resource "aws_s3_bucket" "compliant" {
  expect_failure = false
  attrs = {
    bucket = "basics-count-zero-nothing-to-evalu-0"
    force_destroy = false
  }
}
