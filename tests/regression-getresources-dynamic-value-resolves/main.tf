# REG-BIN-006: getresources with DynamicVal — no panic. VPC must have flow log.
# At plan: attrs.id unknown → UNKNOWN
# At apply: getresources finds flow log → PASS

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_cloudwatch_log_group" "flow_log" {
  name              = "reg-bin-006-flow-logs"
  retention_in_days = 7
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "reg-bin-006-vpc" }
}

resource "aws_flow_log" "main" {
  vpc_id               = aws_vpc.main.id
  traffic_type         = "ALL"
  iam_role_arn         = "arn:aws:iam::992382722822:role/AmazonBedrockAgentCoreSDKRuntime-us-east-1-764090f73a"
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.flow_log.arn
}
