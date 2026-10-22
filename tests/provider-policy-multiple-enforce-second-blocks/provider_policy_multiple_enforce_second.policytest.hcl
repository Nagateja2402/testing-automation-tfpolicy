policytest {
  targets = ["provider_policy_multiple_enforce_second.policy.hcl"]
}

provider "aws" "east" {
  expect_failure = true
  attrs = {
    region = "us-east-1"
  }
  meta = {
    type = "aws"
  }
}
