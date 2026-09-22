# Note: advisory enforcement — condition fails and tfpolicy test marks the resource
# as failed. Use expect_failure=true so the test case passes.
# At the Terraform run level (plan/apply), advisory failure is a warning not a block.

policytest {
  targets = ["advisory.policy.hcl"]
}

# Advisory policy — versioning disabled; condition fails → resource marked fail.
# expect_failure=true → test case passes.
resource "aws_s3_bucket" "advisory_deny_marked_fail_expect_failure_true" {
  expect_failure = true
  attrs = {
    bucket             = "my-bucket"
    versioning = [{ enabled = false }]
  }
}
