policytest {
  targets = ["provider_policy_and_module_policy_meta_input_only.policy.hcl"]
}

provider "aws" "aws" {
  expect_failure = false
  attrs = {
    region = "us-east-1"
  }
  meta = {
    type = "aws"
    version = "6.69.1"
  }
}

module "./modules/q" "q" {
  expect_failure = false
  meta = {
    source = "./modules/q"
    address = "module.q"
  }
}
