policytest {
  targets = ["basics_jsondecode_malformed_value.policy.hcl"]
}

resource "aws_ssm_parameter" "bad_json" {
  expect_failure = true
  attrs = {
    name = "/basics-jsondecode-malformed-value/p"
    type = "String"
    value = "{not valid json"
  }
}
