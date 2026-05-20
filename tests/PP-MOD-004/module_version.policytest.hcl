
policytest {
  targets = ["module_version.policy.hcl"]
}

module "./modules/vpc" "version_meets_minimum_passes" {
  expect_failure = false
  meta = {
    source  = "./modules/vpc"
    version = "2.0.0"
  }
}

module "./modules/vpc" "version_above_minimum_passes" {
  expect_failure = false
  meta = {
    source  = "./modules/vpc"
    version = "3.1.0"
  }
}
