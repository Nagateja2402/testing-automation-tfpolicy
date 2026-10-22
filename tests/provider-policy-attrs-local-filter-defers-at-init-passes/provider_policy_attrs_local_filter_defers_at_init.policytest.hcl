policytest {
  targets = ["provider_policy_attrs_local_filter_defers_at_init.policy.hcl"]
}

provider "aws" "east" {
  expect_failure = false
  attrs = {
    region = "us-east-1"
  }
}
