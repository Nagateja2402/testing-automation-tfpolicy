# Copyright (c) HashiCorp, Inc.

policy {}

module_policy "*" "must_use_approved_source" {
  locals {
    approved_sources = [
      "app.terraform.io/hashicorp/vpc/aws",
      "app.terraform.io/hashicorp/s3-bucket/aws",
      "registry.terraform.io/hashicorp/vpc/aws",
      "./modules/vpc",
      "./modules/s3"
    ]
    source = core::try(meta.source, "")
  }

  enforce {
    condition     = core::contains(local.approved_sources, local.source)
    error_message = "Module source must be from the approved list"
  }
}
