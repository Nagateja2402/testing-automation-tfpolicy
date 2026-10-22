policytest {
  targets = ["provider_policy_aliases_all_allowed.policy.hcl"]
}

provider "aws" "default" {
  expect_failure = false
  attrs = {
    region = "us-east-1"
  }
}

provider "aws" "west" {
  expect_failure = false
  attrs = {
    region = "us-west-2"
  }
}

provider "aws" "east2" {
  expect_failure = false
  attrs = {
    region = "us-east-2"
  }
}
