# Note: advisory failures are marked as fail in policytest (use expect_failure=true);
# mandatory failures also use expect_failure=true.

policytest {
  targets = ["enforcement_regression.policy.hcl"]
}

# Advisory fails — expect_failure=true so test case passes
resource "aws_s3_bucket" "advisory_failure_expect_true" {
  expect_failure = true
  attrs = {
    bucket             = "my-bucket"
    versioning_enabled = false
    tags = {
      Environment = "dev"
    }
  }
}

# Mandatory fails — expect_failure=true so test case passes
resource "aws_s3_bucket" "mandatory_failure_blocks" {
  expect_failure = true
  attrs = {
    bucket             = "my-bucket"
    versioning_enabled = true
    tags               = {}
  }
}
