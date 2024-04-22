data "aws_iam_policy_document" "firehose_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "firehose_policy" {
  statement {
    actions = [
      "kinesis:DescribeStream",
      "kinesis:GetShardIterator",
      "kinesis:GetRecords"
    ]
    resources = [aws_kinesis_stream.affiliate_stream.arn]
  }
  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject"
    ]
    resources = [
      aws_s3_bucket.firehose_target.arn,
      "${aws_s3_bucket.firehose_target.arn}/*"
    ]
  }
  statement {
    actions   = ["logs:PutLogEvents"]
    resources = [aws_cloudwatch_log_stream.firehose_logging_stream.arn]
  }

  dynamic "statement" {
    for_each = length(data.aws_kms_key.key) > 0 ? [var.kms_key_id] : []

    content {
      actions = [
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ]
      resources = [data.aws_kms_key.key[0].arn]
    }
  }

  dynamic "statement" {
    for_each = length(var.kms_key_id) > 0 ? ["1"] : []

    content {
      actions = [
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ]
      resources = [data.aws_kms_key.key[0].arn]
    }
  }
}

resource "aws_iam_role" "firehose_role" {
  name = "${local.resource-name}-firehose"

  assume_role_policy = data.aws_iam_policy_document.firehose_assume_role_policy.json

  inline_policy {
    name   = "firehose_policy"
    policy = data.aws_iam_policy_document.firehose_policy.json
  }

  tags = {
    Environment = var.env
  }
}
#TODO: Ensure firehose role has perms to invoke a provided lambda