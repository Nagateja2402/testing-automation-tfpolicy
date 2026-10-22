policytest {
  targets = ["provider_policy_ternary_default_tags.policy.hcl"]
}

provider "aws" "east_untagged" {
  expect_failure = true
  attrs = {
    region = "us-east-1"
  }
}

provider "aws" "west_untagged" {
  expect_failure = false
  attrs = {
    region = "us-west-2"
  }
}
