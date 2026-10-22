policytest {
  targets = ["module_policy_combined_conditions.policy.hcl"]
}

module "./modules/s3" "s3_match" {
  expect_failure = false
  meta = {
    source = "./modules/s3"
    address = "module.s3_match"
    version = null
  }
}

module "./modules/s3" "bad_name" {
  expect_failure = true
  meta = {
    source = "./modules/s3"
    address = "module.bad_name"
    version = null
  }
}
