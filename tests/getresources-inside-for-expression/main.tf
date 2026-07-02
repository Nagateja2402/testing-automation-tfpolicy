# EC-GR-005: getresources inside a for expression — checks if ANY flow log has traffic_type=ALL.
# At plan time: attrs.id is unknown → UNKNOWN
# At apply time: flow log with traffic_type=ALL exists → PASS

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
  name              = "ec-gr-005-flow-logs"
  retention_in_days = 7
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "ec-gr-005-vpc" }
}

resource "aws_flow_log" "main" {
  vpc_id               = aws_vpc.main.id
  traffic_type         = "ALL"
  iam_role_arn         = "arn:aws:iam::992382722822:role/AmazonBedrockAgentCoreSDKRuntime-us-east-1-764090f73a"
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.flow_log.arn
}
