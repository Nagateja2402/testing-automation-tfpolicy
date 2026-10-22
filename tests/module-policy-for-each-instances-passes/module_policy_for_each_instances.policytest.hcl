policytest {
  targets = ["module_policy_for_each_instances.policy.hcl"]
}

module "./modules/q" "q_a" {
  expect_failure = false
  meta = {
    source = "./modules/q"
    address = "module.q"
  }
}
