policytest {
  targets = ["module_policy_multiple_enforce.policy.hcl"]
}

module "./modules/q" "q" {
  expect_failure = false
  meta = {
    source = "./modules/q"
    address = "module.q"
  }
}
