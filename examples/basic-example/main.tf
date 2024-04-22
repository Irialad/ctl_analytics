terraform {
  required_version = ">= 1.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.45.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.1"
    }
  }
}

locals {
  project_name = "example"
}

module "analytics" {
  source = "../../"

  log_group_name = aws_cloudwatch_log_group.project_log_group.name
  kinesis_data_producers = {
    aws = [aws_iam_role.producer.arn]
  }
  s3_data_consumers = {
    aws = [aws_iam_role.consumer.arn]
  }
  project_name = local.project_name
}

resource "aws_cloudwatch_log_group" "project_log_group" {
  name = local.project_name

  retention_in_days = 30
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "producer" {
  name               = "${local.project_name}-producer"
  assume_role_policy = data.aws_iam_policy_document.this.json
}

resource "aws_iam_role" "consumer" {
  name               = "${local.project_name}-consumer"
  assume_role_policy = data.aws_iam_policy_document.this.json
}
