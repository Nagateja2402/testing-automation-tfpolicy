# Note: null filter value should not panic; getresources returns empty or matches gracefully.

policytest {
  targets = ["gr_null_filter.policy.hcl"]
}

resource "aws_vpc" "null_filter_value_passes_gracefully" {
  expect_failure = false
  attrs = {
    id         = "vpc-abc123"
    cidr_block = "10.0.0.0/16"
    # owner_id absent — core::try returns null
  }
}
