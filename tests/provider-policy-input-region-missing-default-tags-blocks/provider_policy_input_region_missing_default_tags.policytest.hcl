policytest {
  targets = ["provider_policy_input_region_missing_default_tags.policy.hcl"]
}

provider "aws" "east_no_default_tags" {
  expect_failure = true
  attrs = {
    region = "us-east-1"
  }
}

provider "aws" "west_filtered_out" {
  expect_failure = false
  attrs = {
    region = "us-west-2"
  }
}
