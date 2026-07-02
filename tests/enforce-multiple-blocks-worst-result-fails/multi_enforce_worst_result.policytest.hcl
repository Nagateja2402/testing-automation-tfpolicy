
policytest {
  targets = ["multi_enforce_worst_result.policy.hcl"]
}

# First enforce fails (no Environment tag), second passes (bucket present).
# Worst result: deny.
resource "aws_s3_bucket" "first_fails_second_passes_deny_wins" {
  expect_failure = true
  attrs = {
    bucket = "my-bucket"
    tags   = {}
  }
}

# Both pass.
resource "aws_s3_bucket" "both_pass" {
  expect_failure = false
  attrs = {
    bucket = "my-bucket"
    tags = {
      Environment = "dev"
    }
  }
}
