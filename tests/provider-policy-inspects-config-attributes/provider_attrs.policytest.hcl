# Note: attrs in a provider_policy is not a compile error; the policy evaluates
# and passes because the condition using attrs.region evaluates to true with
# attrs = { region = "us-east-1" }.

policytest {
  targets = ["provider_attrs.policy.hcl"]
}

provider "aws" "attrs_in_provider_policy_evaluates" {
  expect_failure = false
  attrs = {
    region = "us-east-1"
  }
  meta = {
    type = "aws"
  }
}
