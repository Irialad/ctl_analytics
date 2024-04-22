resource "random_string" "random" {
  length  = 6
  special = false
  upper   = false
}

resource "aws_s3_bucket" "firehose_target" {
  bucket        = "${lower(local.resource-name)}-${random_string.random.result}"
  force_destroy = true

  tags = {
    Environment = var.env
  }
}

## Lock down access to the bucket
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.firehose_target.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.firehose_target.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encrypt" {
  bucket = aws_s3_bucket.firehose_target.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.use_kms_for_s3 ? var.kms_key_id : null
      sse_algorithm     = var.use_kms_for_s3 ? "aws:kms" : "AES256"
    }

    bucket_key_enabled = true
  }

  lifecycle {
    precondition {
      condition     = var.use_kms_for_s3 ? length(var.kms_key_id) > 0 : true
      error_message = "The variable kms_key_id must be provided if use_kms_for_s3 is true."
    }
  }
}

locals {
  aws_consumers       = coalesce(var.s3_data_consumers.aws, [])
  federated_consumers = coalesce(var.s3_data_consumers.federated, [])
}

data "aws_iam_policy_document" "bucket_policy" {
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
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.firehose_role.arn]
    }
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]

    dynamic "principals" {
      for_each = length(local.aws_consumers) > 0 ? ["1"] : []

      content {
        type        = "AWS"
        identifiers = local.aws_consumers
      }
    }
    dynamic "principals" {
      for_each = length(local.federated_consumers) > 0 ? ["1"] : []

      content {
        type        = "Federated"
        identifiers = local.federated_consumers
      }
    }
    resources = [
      aws_s3_bucket.firehose_target.arn,
      "${aws_s3_bucket.firehose_target.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.firehose_target.id
  policy = data.aws_iam_policy_document.bucket_policy.json

  lifecycle {
    precondition {
      condition = (
        (length(local.aws_consumers) + length(local.federated_consumers)) > 0
      ) ? true : false
      error_message = "There must be at least one consumer principal to read from the S3 bucket"
    }
  }
}
