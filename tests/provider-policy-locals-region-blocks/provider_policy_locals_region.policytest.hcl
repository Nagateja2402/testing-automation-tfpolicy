policytest {
  targets = ["provider_policy_locals_region.policy.hcl"]
}

provider "aws" "west" {
  expect_failure = true
  attrs = {
    region = "us-west-2"
  }
}
