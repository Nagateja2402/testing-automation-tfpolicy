policytest {
  targets = ["provider_policy_ternary_default_tags.policy.hcl"]
}

provider "aws" "east_tagged" {
  expect_failure = false
  attrs = {
    region = "us-east-1"
    default_tags = {
      tags = { Env = "prod" }
    }
  }
}

provider "aws" "west_untagged" {
  expect_failure = false
  attrs = {
    region = "us-west-2"
  }
}
