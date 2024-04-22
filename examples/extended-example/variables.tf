variable "alarm_subscription_email_addresses" {
  description = "The set of email addresses to subscribe to alarm notifications"
  default     = []
  type        = set(string)
}

variable "env" {
  description = "Current deployment environment name"
  default     = "Dev"
  type        = string
}

variable "retention_period" {
  description = "The number of hours records remain accessible in the kinesis stream"
  default     = 24
  type        = number
}

variable "shard_count" {
  description = "The number of shards that the stream will use, ignored if stream_mode is 'ON_DEMAND'"
  default     = 1
  type        = number
}

variable "stream_mode" {
  description = "The capacity mode for the stream"
  default     = "ON_DEMAND"
  type        = string
}
