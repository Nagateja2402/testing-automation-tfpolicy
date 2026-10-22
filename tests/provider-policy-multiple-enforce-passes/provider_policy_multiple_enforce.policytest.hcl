policytest {
  targets = ["provider_policy_multiple_enforce.policy.hcl"]
}

provider "aws" "east" {
  expect_failure = false
  attrs = {
    region = "us-east-1"
  }
  meta = {
    type = "aws"
  }
}
