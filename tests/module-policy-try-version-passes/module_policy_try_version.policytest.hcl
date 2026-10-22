policytest {
  targets = ["module_policy_try_version.policy.hcl"]
}

module "hashicorp/dir/template" "dirmod" {
  expect_failure = false
  meta = {
    source = "hashicorp/dir/template"
    version = "1.0.2"
    address = "module.dirmod"
  }
}
