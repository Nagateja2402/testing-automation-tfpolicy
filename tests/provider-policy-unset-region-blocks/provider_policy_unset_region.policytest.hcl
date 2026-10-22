policytest {
  targets = ["provider_policy_unset_region.policy.hcl"]
}

provider "aws" "no_region" {
  expect_failure = true
  attrs = {
    region = null
  }
}
