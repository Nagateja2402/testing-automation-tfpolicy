policytest {
  targets = ["provider_policy_regex_region.policy.hcl"]
}

provider "aws" "eu" {
  expect_failure = true
  attrs = {
    region = "eu-west-1"
  }
}
