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

  alarm_high_threshold               = 20000
  alarm_low_threshold                = 5000
  alarm_subscription_email_addresses = var.alarm_subscription_email_addresses

  buffering_interval = 60
  buffering_size     = 6

  env = var.env

  log_group_name = aws_cloudwatch_log_group.project_log_group.name
  project_name   = local.project_name

  retention_period = var.retention_period
  shard_count      = var.shard_count
  stream_mode      = var.stream_mode

  kms_key_id          = aws_kms_key.key.id
  use_kms_for_kinesis = true
  use_kms_for_s3      = true

  # Required IAM roles
  kinesis_data_producers = {
    aws = [aws_iam_role.producer.arn]
  }
  s3_data_consumers = {
    aws = [aws_iam_role.consumer.arn]
  }
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

# Note that this example is using AWS default key policy. This is not recommended for production!
resource "aws_kms_key" "key" {
  description = "Key used for encrypting ${local.project_name}'s pipeline"
}

# Exposing the module's outputs
output "affiliate_kinesis_stream_arn" {
  value       = module.analytics.affiliate_kinesis_stream_arn
  description = "The ARN of the Kinesis stream accepting source input for the analytics pipeline"
}

output "firehose_role_arn" {
  value       = module.analytics.firehose_role_arn
  description = <<-EOT
    The ARN of the role Firehose will use, particularly to call any supplied Lambdas.
  EOT
}

output "target_s3_bucket_name" {
  value       = module.analytics.target_s3_bucket_name
  description = "The S3 bucket to which Firehose will write output"
}

output "cloudwatch_dashboard_url" {
  value       = module.analytics.cloudwatch_dashboard_url
  description = "Link to the created dashboard"
}
