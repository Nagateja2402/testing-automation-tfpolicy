policytest {
  targets = ["provider_policy_alias_disallowed.policy.hcl"]
}

provider "aws" "west" {
  expect_failure = false
  attrs = {
    region = "us-west-2"
  }
}

provider "aws" "eu" {
  expect_failure = true
  attrs = {
    region = "eu-west-1"
  }
}
