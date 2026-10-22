policytest {
  targets = ["module_policy_multiple_enforce_second.policy.hcl"]
}

module "./modules/q" "q" {
  expect_failure = true
  meta = {
    source = "./modules/q"
    address = "module.q"
  }
}
