policytest {
  targets = ["enforcement_level_misspelled_mandatory_override.policy.hcl"]
}

resource "aws_s3_bucket" "q" {
  expect_failure = true
  attrs = {
    bucket = "enforcement-level-misspelled-manda-q"
      tags = { Env = "prod" }
  }
}
