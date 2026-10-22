policytest {
  targets = ["module_policy_try_missing_version.policy.hcl"]
}

module "./modules/s3" "s3_match" {
  expect_failure = true
  meta = {
    source = "./modules/s3"
    address = "module.s3_match"
  }
}
