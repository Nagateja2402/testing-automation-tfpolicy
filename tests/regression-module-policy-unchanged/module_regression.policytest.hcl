
policytest {
  targets = ["module_regression.policy.hcl"]
}

module "./modules/vpc" "approved_module_source_regression_passes" {
  expect_failure = false
  meta = {
    source = "./modules/vpc"
  }
}
