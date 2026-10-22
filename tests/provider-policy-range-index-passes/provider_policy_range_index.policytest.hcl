policytest {
  targets = ["provider_policy_range_index.policy.hcl"]
}

provider "aws" "east" {
  expect_failure = false
  attrs = {
    region = "us-east-1"
  }
}
