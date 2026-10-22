policytest {
  targets = ["provider_policy_default_tags_map.policy.hcl"]
}

provider "aws" "tagged" {
  expect_failure = false
  attrs = {
    region = "us-east-1"
    default_tags = {
      tags = { Env = "prod" }
    }
  }
}
