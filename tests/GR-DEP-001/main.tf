# GR-DEP-001: VPC with associated flow log — happy path
# tfp plan: PASS (vpc_id resolves at plan time, flow log found with traffic_type=ALL)
# tfp apply: PASS (all values resolved, flow log found with traffic_type=ALL)

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_cloudwatch_log_group" "flow_log" {
  name              = "gr-dep-001-flow-logs-v2"
  retention_in_days = 7
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "gr-dep-001-vpc" }
}

resource "aws_flow_log" "main" {
  vpc_id               = aws_vpc.main.id
  traffic_type         = "ALL"
  iam_role_arn         = "arn:aws:iam::992382722822:role/AmazonBedrockAgentCoreSDKRuntime-us-east-1-764090f73a"
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.flow_log.arn
}
