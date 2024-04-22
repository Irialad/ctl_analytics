output "affiliate_kinesis_stream_arn" {
  value       = aws_kinesis_stream.affiliate_stream.arn
  description = <<-EOT
    The ARN of the Kinesis stream accepting source input for the analytics pipeline.
    This will be needed to provide that appropriate permissions data producers' roles.
  EOT
}

output "firehose_role_arn" {
  value       = aws_iam_role.firehose_role.arn
  description = <<-EOT
    The ARN of the role Firehose will use.
    This will be useful in resource policies such as:
    * Data transformation Lambda
    * KMS key policy
  EOT
}

output "target_s3_bucket_name" {
  value       = aws_s3_bucket.firehose_target.bucket
  description = "The S3 bucket to which Firehose will write output"
}

output "cloudwatch_dashboard_url" {
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards/dashboard/${aws_cloudwatch_dashboard.this.dashboard_name}"
  description = "Link to the created dashboard"
}
