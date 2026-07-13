# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Test for feature: feature_metaarg_enforcement_advisory
# Asserts        : advisory failure does not fail the test
# =============================================================================

policytest {
  targets = ["feature_metaarg_enforcement_advisory.policy.hcl"]
}


# The rule's condition is always false; under the current test framework
# semantics, any Deny — advisory or not — counts as a failure, so the test
# asserts the failure happens. Enforcement-level severity is what changes
# downstream (advisory = warning), not whether the test framework sees a Deny.
resource "aws_s3_bucket" "advisory_denied" {
  expect_failure = true
  attrs = { bucket = "x" }
  meta  = { provider_type = "aws" }
}
