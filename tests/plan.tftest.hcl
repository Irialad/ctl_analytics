provider "aws" {
  region = "us-west-2"
}

variables {
  log_group_name = "logs"
  kinesis_data_producers = {
    aws = ["arn:aws:iam::123456789012:role/ec2_app/kinesis_role"]
  }
  s3_data_consumers = {
    aws = ["arn:aws:iam::123456789012:role/glue_app/pipeline_role"]
  }
  project_name = "test"
}

run "basic_plan_succeeds" {
  command = plan
}

run "extended_plan_succeeds" {
  command = plan

  variables {
    alarm_high_threshold               = 20000
    alarm_low_threshold                = 5000
    alarm_subscription_email_addresses = ["test@tests.com"]

    buffering_interval = 60
    buffering_size     = 128

    env = "Prod"

    retention_period = 48
    shard_count      = 10000
    stream_mode      = "PROVISIONED"

    kms_key_id          = "alias/aws/kinesis"
    use_kms_for_kinesis = true
    use_kms_for_s3      = true
  }
}

run "plan_with_data_transform_succeeds" {
  command = plan

  variables {
    data_transformation_lambda_arn = "arn:aws:lambda:us-east-2:123456789012:function:my-function:1"
  }
}

run "plan_with_dynamic_partitioning_succeeds" {
  command = plan

  variables {
    enable_dynamic_partitioning = true
    dynamic_partitioning_config = {
      jq_metadata_query = "{customer_id:.customer_id}"
      s3_dynamic_prefix = "data/customer_id=!{partitionKeyFromQuery:customer_id}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"
      s3_error_prefix   = "errors/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/!{firehose:error-output-type}/"
    }
  }
}
