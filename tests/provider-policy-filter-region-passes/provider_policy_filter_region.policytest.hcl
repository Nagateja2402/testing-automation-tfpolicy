policytest {
  targets = ["provider_policy_filter_region.policy.hcl"]
}

provider "aws" "east" {
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
