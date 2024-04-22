resource "aws_cloudwatch_log_stream" "firehose_logging_stream" {
  log_group_name = var.log_group_name
  name           = local.resource-name
}

resource "aws_cloudwatch_dashboard" "this" {
  dashboard_name = "${local.resource-name}-FirehoseMonitoring"
  dashboard_body = jsonencode({
    widgets = [{
      type   = "metric"
      height = 10,
      width  = 24,
      x      = 0,
      y      = 0,

      properties = {
        metrics = [
          ["AWS/Firehose", "DeliveryToS3.Bytes",
            "DeliveryStreamName", aws_kinesis_firehose_delivery_stream.affiliate_firehose.name,
          { "yAxis" : "right" }],
          [".", "DataReadFromKinesisStream.Records", ".", ".", {}]
        ]
        view      = "timeSeries"
        region    = data.aws_region.current.name
        stacked   = false
        statistic = "Sum"
      }
    }]
  })
}

resource "aws_cloudwatch_metric_alarm" "firehose_incoming_records_high_alarm" {
  alarm_name          = "${local.resource-name}-high-incoming-records"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "DataReadFromKinesisStream.Records"
  namespace           = "AWS/Firehose"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.alarm_high_threshold
  alarm_description   = "Alarm when the number of incoming records is too high"

  dimensions = {
    DeliveryStreamName = aws_kinesis_firehose_delivery_stream.affiliate_firehose.name
  }

  alarm_actions = [
    aws_sns_topic.firehose-alarms.arn
  ]

  tags = {
    Environment = var.env
  }
}

resource "aws_cloudwatch_metric_alarm" "firehose_incoming_records_low_alarm" {
  alarm_name          = "${local.resource-name}-low-incoming-records"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "DataReadFromKinesisStream.Records"
  namespace           = "AWS/Firehose"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.alarm_low_threshold
  alarm_description   = "Alarm when the number of incoming records is too high"

  dimensions = {
    DeliveryStreamName = aws_kinesis_firehose_delivery_stream.affiliate_firehose.name
  }

  alarm_actions = [
    aws_sns_topic.firehose-alarms.arn
  ]

  tags = {
    Environment = var.env
  }
}

resource "aws_sns_topic" "firehose-alarms" {
  name = "${local.resource-name}-alarms"

  tags = {
    Environment = var.env
  }
}

resource "aws_sns_topic_subscription" "alarm_subscriptions" {
  for_each = var.alarm_subscription_email_addresses

  topic_arn = aws_sns_topic.firehose-alarms.arn
  protocol  = "email"
  endpoint  = each.key
}
