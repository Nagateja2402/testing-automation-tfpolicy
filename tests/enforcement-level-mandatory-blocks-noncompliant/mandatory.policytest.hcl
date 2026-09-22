
policytest {
  targets = ["mandatory.policy.hcl"]
}

# Mandatory policy — versioning disabled; condition fails and run is blocked.
resource "aws_s3_bucket" "mandatory_deny_blocks_run" {
  expect_failure = true
  attrs = {
    bucket             = "my-bucket"
    versioning = [{ enabled = false }]
  }
}
