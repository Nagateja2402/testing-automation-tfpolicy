policytest {
  targets = ["provider_policy_range_index.policy.hcl"]
}

provider "aws" "eu" {
  expect_failure = true
  attrs = {
    region = "eu-west-1"
  }
}
