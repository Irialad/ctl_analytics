resource "aws_kinesis_stream" "affiliate_stream" {
  name             = local.resource-name
  retention_period = var.retention_period

  encryption_type = var.use_kms_for_kinesis ? "KMS" : "NONE"
  kms_key_id      = var.use_kms_for_kinesis ? data.aws_kms_key.key[0].arn : null

  stream_mode_details {
    stream_mode = var.stream_mode
  }

  shard_count = var.stream_mode == "ON_DEMAND" ? null : var.shard_count

  tags = {
    Environment = var.env
  }

  lifecycle {
    precondition {
      condition     = var.use_kms_for_kinesis ? length(var.kms_key_id) > 0 : true
      error_message = "The variable kms_key_id must be provided if use_kms_for_kinesis is true."
    }
  }
}

locals {
  aws_producers       = coalesce(var.kinesis_data_producers.aws, [])
  federated_producers = coalesce(var.kinesis_data_producers.federated, [])
}

data "aws_iam_policy_document" "stream_policy" {
  statement {
    actions = [
      "kinesis:DescribeStreamSummary",
      "kinesis:ListShards",
      "kinesis:PutRecord",
      "kinesis:PutRecords"
    ]

    dynamic "principals" {
      for_each = length(local.aws_producers) > 0 ? ["1"] : []

      content {
        type        = "AWS"
        identifiers = local.aws_producers
      }
    }
    dynamic "principals" {
      for_each = length(local.federated_producers) > 0 ? ["1"] : []

      content {
        type        = "Federated"
        identifiers = local.federated_producers
      }
    }
    resources = [aws_kinesis_stream.affiliate_stream.arn]
  }

  statement {
    actions = [
      "kinesis:DescribeStream",
      "kinesis:GetShardIterator",
      "kinesis:GetRecords"
    ]
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.firehose_role.arn]
    }
    resources = [aws_kinesis_stream.affiliate_stream.arn]
  }
}

resource "aws_kinesis_resource_policy" "this" {
  resource_arn = aws_kinesis_stream.affiliate_stream.arn

  policy = data.aws_iam_policy_document.stream_policy.json

  lifecycle {
    precondition {
      condition = (
        length(local.aws_producers) + length(local.federated_producers) < 1
      ) ? false : true
      error_message = "There must be at least one producer principal to write to the Kinesis stream"
    }
  }
}
