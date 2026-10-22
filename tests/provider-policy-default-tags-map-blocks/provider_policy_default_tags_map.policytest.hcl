policytest {
  targets = ["provider_policy_default_tags_map.policy.hcl"]
}

provider "aws" "untagged" {
  expect_failure = true
  attrs = {
    region = "us-east-1"
  }
}
