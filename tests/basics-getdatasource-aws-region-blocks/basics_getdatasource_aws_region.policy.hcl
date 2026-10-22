# Copyright (c) HashiCorp, Inc.
policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

resource_policy "aws_s3_bucket" "region_from_datasource" {
  locals {
    ds     = core::getdatasource("aws_region", {})
    region = core::try(local.ds.region, local.ds.name)
  }
  enforce {
    condition     = local.region == "us-west-2"
    error_message = "data source region '${local.region}' must be us-west-2"
  }
}
