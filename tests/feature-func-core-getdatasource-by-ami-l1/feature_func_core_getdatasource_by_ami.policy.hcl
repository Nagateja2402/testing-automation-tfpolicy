# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# =============================================================================
# Feature: feature_func_core_getdatasource_by_ami
# Covers : core::getdatasource filtered by a resource attribute (an instance's
#          own ami id) to resolve the backing aws_ami data source
# =============================================================================

resource_policy "aws_instance" "feature_func_core_getdatasource_by_ami" {
  # Resolve the aws_ami data source backing this instance by filtering on the
  # instance's own `ami` attribute, then enforce a property on the resolved
  # AMI. The positive path is pinned by a matching data block in the
  # policytest fixture.
  locals {
      ami_data = core::getdatasource("aws_ami", {
      filter = [{
        name   = "image-id"
        values = [attrs.ami]
      }]
    })
  }
  enforce {
    condition    = local.ami_data.architecture == "x86_64"
    info_message = "core::getdatasource resolved ami ${local.ami_data.id} (architecture = ${local.ami_data.architecture})"
  }
}
