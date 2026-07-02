
policytest {
  targets = ["multiple_enforce.policy.hcl"]
}

resource "aws_s3_bucket" "name_and_owner_passes" {
  expect_failure = false
  attrs = {
    bucket = "team-data-bucket"
    tags = {
      Owner = "platform-team"
    }
  }
}

resource "aws_s3_bucket" "missing_owner_fails" {
  expect_failure = true
  attrs = {
    bucket = "team-data-bucket"
  }
}
