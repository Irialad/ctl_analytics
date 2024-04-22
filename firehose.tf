locals {
  enable_processing = length(var.data_transformation_lambda_arn) > 0 || (
    var.enable_dynamic_partitioning &&
    coalesce(
      var.dynamic_partitioning_config.enable_newline_appending,
      var.dynamic_partitioning_config.enable_record_deaggregation,
      false
    )
  )
}

resource "aws_kinesis_firehose_delivery_stream" "affiliate_firehose" {
  name        = local.resource-name
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.firehose_role.arn
    bucket_arn         = aws_s3_bucket.firehose_target.arn
    buffering_size     = var.buffering_size
    buffering_interval = var.buffering_interval
    compression_format = "GZIP"

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = var.log_group_name
      log_stream_name = aws_cloudwatch_log_stream.firehose_logging_stream.name
    }

    dynamic_partitioning_configuration {
      enabled = var.enable_dynamic_partitioning
    }

    prefix              = var.dynamic_partitioning_config.s3_dynamic_prefix
    error_output_prefix = var.dynamic_partitioning_config.s3_error_prefix

    processing_configuration {
      enabled = local.enable_processing

      dynamic "processors" {
        for_each = var.enable_dynamic_partitioning ? ["1"] : []

        content {
          type = "MetadataExtraction"

          parameters {
            parameter_name  = "JsonParsingEngine"
            parameter_value = "JQ-1.6"
          }
          parameters {
            parameter_name  = "MetadataExtractionQuery"
            parameter_value = var.dynamic_partitioning_config.jq_metadata_query
          }
        }
      }

      dynamic "processors" {
        for_each = coalesce(var.dynamic_partitioning_config.enable_newline_appending, false) ? ["1"] : []

        content {
          type = "AppendDelimiterToRecord"
        }
      }

      dynamic "processors" {
        for_each = length(var.data_transformation_lambda_arn) > 0 ? ["1"] : []

        content {
          type = "Lambda"

          parameters {
            parameter_name  = "LambdaArn"
            parameter_value = var.data_transformation_lambda_arn
          }
        }
      }

      dynamic "processors" {
        for_each = coalesce(var.dynamic_partitioning_config.enable_record_deaggregation, false) ? ["1"] : []

        content {
          type = "RecordDeAggregation"
          parameters {
            parameter_name  = "SubRecordType"
            parameter_value = coalesce(var.dynamic_partitioning_config.record_deaggregation_config.type, "JSON")
          }

          dynamic "parameters" {
            for_each = (
              coalesce(var.dynamic_partitioning_config.record_deaggregation_config.type, "JSON") == "DELIMITED" ?
            ["1"] : [])

            content {
              parameter_name  = "Delimiter"
              parameter_value = var.dynamic_partitioning_config.record_deaggregation_config.delimiter
            }
          }
        }
      }
    }
  }

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.affiliate_stream.arn
    role_arn           = aws_iam_role.firehose_role.arn
  }

  tags = {
    Environment = var.env
  }

  lifecycle {
    precondition {
      condition = var.enable_dynamic_partitioning ? (
        length(var.dynamic_partitioning_config.s3_dynamic_prefix) > 0 ||
        length(var.dynamic_partitioning_config.s3_error_prefix) > 0
      ) : true

      error_message = "dynamic_partitioning_config for S3 settings are required when dynamic partitioning is enabled"
    }
  }
}
