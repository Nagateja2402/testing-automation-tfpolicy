# resource_policy sets enforcement_level = "mandatory"; bucket fails condition → blocks.

policytest {
  targets = ["enforcement_override.policy.hcl"]
}

resource "aws_s3_bucket" "mandatory_blocks_when_versioning_missing" {
  expect_failure = true
  attrs = {
    bucket             = "my-bucket"
    versioning = [{ enabled = false }]
  }
}
