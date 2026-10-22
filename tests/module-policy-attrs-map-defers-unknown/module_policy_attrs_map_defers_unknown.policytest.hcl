policytest {
  targets = ["module_policy_attrs_map_defers_unknown.policy.hcl"]
}

module "./modules/q" "q" {
  expect_failure = false
  attrs = {
    name = "module-policy-attrs-map-defers-unk-q"
    tags = { owner = "platform", env = "dev" }
  }
  meta = {
    source = "./modules/q"
    address = "module.q"
  }
}
