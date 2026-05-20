
policytest {
  targets = ["module_version.policy.hcl"]
}

module "./modules/vpc" "version_below_minimum_fails" {
  expect_failure = true
  meta = {
    source  = "./modules/vpc"
    version = "1.9.9"
  }
}

module "./modules/vpc" "version_not_set_fails" {
  expect_failure = true
  meta = {
    source = "./modules/vpc"
  }
}
