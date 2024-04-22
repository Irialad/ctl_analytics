## General variables
variable "env" {
  description = "Current deployment environment name ('Dev', 'Test', or 'Prod')"
  default     = "Dev"
  type        = string

  validation {
    condition     = contains(["Dev", "Test", "Prod"], var.env)
    error_message = "Environment must be set to one of 'Dev', 'Test', or 'Prod'"
  }
}

variable "project_name" {
  description = "Name of the project this module is being included in, used when naming resourcces"
  type        = string
}

locals {
  resource-name = "${var.project_name}-${var.env}"
}

## Kinesis variables
variable "kinesis_data_producers" {
  description = <<-EOT
    Map of principals allowed to put records into the Kinesis stream

    Example:
    ```
    kinesis_data_producers = {
      aws = [
        "arn:aws:iam::123456789012:user/JohnDoe",
        "arn:aws:iam::123456789012:role/ec2_app/kinesis_role"

      ]
      federated = ["arn:aws:iam::123456789012:saml-provider/okta"]
    }
    ```
  EOT
  type = object({
    aws       = optional(set(string))
    federated = optional(set(string))
  })
}

variable "retention_period" {
  description = "The number of hours records remain accessible in the Kinesis stream"
  default     = 24
  type        = number

  validation {
    condition     = 24 <= var.retention_period && var.retention_period <= 8760
    error_message = "Retention period must be between 24 and 8760 hours, inclusive"
  }
}

variable "shard_count" {
  description = "The number of shards that the Kinesis stream will use, ignored if stream_mode is 'ON_DEMAND'"
  default     = 1
  type        = number
}

variable "stream_mode" {
  description = "The capacity mode for the Kinesis stream ('PROVISIONED', or 'ON_DEMAND')"
  default     = "ON_DEMAND"
  type        = string

  validation {
    condition     = contains(["PROVISIONED", "ON_DEMAND"], var.stream_mode)
    error_message = "Stream mode must be one of 'PROVISIONED', or 'ON_DEMAND'"
  }
}

## Firehose variables
variable "buffering_interval" {
  description = <<-EOT
    Buffer incoming data for the specified period of time, in seconds, before delivering it to the destination
    Note that both this and `buffering_size` may be set
  EOT
  default     = 400
  type        = number
}

variable "buffering_size" {
  description = <<-EOT
    Buffer incoming data to the specified size, in MBs, before delivering it to the destination
    Note that both this and `buffering_interval` may be set
  EOT
  default     = 10
  type        = number
}

variable "data_transformation_lambda_arn" {
  description = <<-EOT
    The ARN of a lambda to use if data transformation in FireHose is desired
    To control which revision is executed, ensure you specify it in the ARN
  EOT
  default     = ""
  type        = string
}

variable "dynamic_partitioning_config" {
  description = <<-EOT
    Supply a configuration object if you wish to use dynamic partitioning
    If this is true, you must provide the jq_metadata_query, and s3_dynamic_prefix, s3_error_prefix
    See the AWS blog [post](https://aws.amazon.com/blogs/big-data/kinesis-data-firehose-now-supports-dynamic-partitioning-to-amazon-s3/) and [documentation](https://docs.aws.amazon.com/firehose/latest/dev/dynamic-partitioning.html) for more information

    Of particular note:
    > When you use the Data Transformation feature in Firehose, the deaggregation will be applied before the Data Transformation.
    > Data coming into Firehose will be processed in the following order: Deaggregation → Data Transformation via Lambda → Partitioning Keys.
  EOT
  default     = {}
  type = object({
    jq_metadata_query = optional(string, "")
    s3_dynamic_prefix = optional(string, "")
    s3_error_prefix   = optional(string, "")

    enable_newline_appending    = optional(bool, false)
    enable_record_deaggregation = optional(bool, false)
    record_deaggregation_config = optional(object({
      type      = optional(string, "JSON")
      delimiter = optional(string, "")
    }), {})
  })

  validation {
    error_message = "If enabling record deaggregation, type must be either 'JSON' or 'Delimited'"
    condition = (
      # True if we're not configured at all
      var.dynamic_partitioning_config == {}) ? true : (
      # Now, if we're doing record deaggregation...
      coalesce(var.dynamic_partitioning_config.enable_record_deaggregation, false) ? (
        # It's only allowed to be one of two values
        contains(["JSON", "Delimited"], var.dynamic_partitioning_config.record_deaggregation_config.type)
      ) : true
    )
  }
  validation {
    error_message = "If enabling delimited record deaggregation, you must supply the delimiter"
    condition = (
      # True if we're not configured at all
      var.dynamic_partitioning_config == {}) ? true : (
      # Now, if we're doing record deaggregation...
      coalesce(var.dynamic_partitioning_config.enable_record_deaggregation, false) ? (
        # And it's "Delimited"...
        var.dynamic_partitioning_config.record_deaggregation_config.type == "Delimited" ? (
          # We demand a delimiter
          length(var.dynamic_partitioning_config.record_deaggregation_config.delimiter) > 0 ? true : false
        ) : true
      ) : true
    )
  }
}

variable "enable_dynamic_partitioning" {
  description = <<-EOT
    Whether to enable Firehose's dynamic partitioning
    `dynamic_partitioning_config` must be supplied if `true`

    |    Changing this after creation will force destruction and recreation of the Firehose stream!    |
    |--------------------------------------------------------------------------------------------------|
  EOT
  default     = false
  type        = bool
}

## S3 variables
variable "s3_data_consumers" {
  description = <<-EOT
    Map of principals allowed to read from the target s3 bucket

    Example:
    ```
    s3_dataconsumers = {
      aws = [
        "arn:aws:iam::123456789012:user/JohnDoe",
        "arn:aws:iam::123456789012:role/ec2_app/kinesis_role"

      ]
      federated = ["arn:aws:iam::123456789012:saml-provider/okta"]
    }
    ```
  EOT
  type = object({
    aws       = optional(set(string))
    federated = optional(set(string))
  })
}

## Logging variables
variable "log_group_name" {
  description = "The name of the log group in which to create the firehose logging stream"
  type        = string
}

variable "alarm_high_threshold" {
  description = <<-EOT
    The number of incoming records during a 5 minute period above which which the alarm should trigger
  EOT
  default     = 1000
  type        = number
}

variable "alarm_low_threshold" {
  description = <<-EOT
    The number of incoming records during a 5 minute period below which which the alarm should trigger
  EOT
  default     = 50
  type        = number
}

variable "alarm_subscription_email_addresses" {
  description = <<-EOT
    The set of email addresses to subscribe to alarm notifications
    Each will receive an initial email asking to confirm the subscription
  EOT
  default     = []
  type        = set(string)
}

## Encryption variables
variable "kms_key_id" {
  description = <<-EOT
    The KMS key to use for encryption
    Note that this is required if either `use_kms_for_kinesis` or `use_kms_for_s3` are true
    Note also that the key policy will need to permit the firehose role `firehose_role_arn` to do certain actions:
    * `kms:Decrypt` if used for Kinesis
    * `kms:GenerateDataKey` if used for S3
  EOT
  default     = ""
  type        = string
}

variable "use_kms_for_kinesis" {
  description = "Use KMS key provided in `kms_key_id` for encryption of data in kinesis"
  default     = false
  type        = bool
}

variable "use_kms_for_s3" {
  description = "Use KMS key provided in `kms_key_id` for S3 encryption (This is required for cross-account access)"
  default     = false
  type        = bool
}