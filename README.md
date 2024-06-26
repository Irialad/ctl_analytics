# Real-Time Analytics with Spark Streaming Ver 1.3
This module provides a configurable set of AWS infrastructure for real-time analytics. While you can view the full set of AWS resources below, the data pipeline this module produces uses three core things: Kinesis, Firehose, and S3.

## How To Use This Module
To reference this module from your project's terraform, add a `module` block to your existing Terraform.

For example, this block would explicitly make use of the `1.3.0` version of this module.
Note that this example shows the minimally required arguments.

``` terraform
module "analytics" {
  source = "../../"

  project_name   = "example"

  log_group_name = aws_cloudwatch_log_group.project_log_group.name
  kinesis_data_producers = {
    aws = [aws_iam_role.producer.arn]
  }
  s3_data_consumers = {
    aws = [aws_iam_role.consumer.arn]
  }
}
```
See [examples](./examples) for more, or the variable and output reference [below](#autogenerated-module-documentation).

## How To Contribute
1. Clone this repo: `git clone git@github.com:<org>/<repo>`
2. Prepare the environment `cd <repo>; scripts/prep.sh`
3. Source useful functions `. scripts/functions.sh`

### Provided functions
| Function  | Description |
| :-------- | ----------: |
| `dev-start` | This launches the development container interactively, useful if you want to `plan` or `apply` the examples. |
| `dev-docs`  | Uses [terraform-docs](https://terraform-docs.io/) to update documentation. |
| `dev-fmt`   | Runs `terraform fmt` |
| `dev-lint`  | Uses [tflint](https://github.com/terraform-linters/tflint/tree/master/docs/user-guide) to lint the terraform. |
| `dev-test`  | Runs `terraform test` |

### Note
The only tooling required on a contributor machine is `git` and `docker`.

# Module documentation
<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.8)

- <a name="requirement_aws"></a> [aws](#requirement\_aws) (>= 5.45.0)

- <a name="requirement_random"></a> [random](#requirement\_random) (>= 3.6.1)

## Providers

The following providers are used by this module:

- <a name="provider_aws"></a> [aws](#provider\_aws) (>= 5.45.0)

- <a name="provider_random"></a> [random](#provider\_random) (>= 3.6.1)

## Resources

The following resources are used by this module:

- [aws_cloudwatch_dashboard.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_dashboard) (resource)
- [aws_cloudwatch_log_stream.firehose_logging_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_stream) (resource)
- [aws_cloudwatch_metric_alarm.firehose_incoming_records_high_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) (resource)
- [aws_cloudwatch_metric_alarm.firehose_incoming_records_low_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) (resource)
- [aws_iam_role.firehose_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) (resource)
- [aws_kinesis_firehose_delivery_stream.affiliate_firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_firehose_delivery_stream) (resource)
- [aws_kinesis_resource_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_resource_policy) (resource)
- [aws_kinesis_stream.affiliate_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_stream) (resource)
- [aws_s3_bucket.firehose_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) (resource)
- [aws_s3_bucket_ownership_controls.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) (resource)
- [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) (resource)
- [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) (resource)
- [aws_s3_bucket_server_side_encryption_configuration.encrypt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) (resource)
- [aws_sns_topic.firehose-alarms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) (resource)
- [aws_sns_topic_subscription.alarm_subscriptions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) (resource)
- [random_string.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) (resource)
- [aws_iam_policy_document.bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
- [aws_iam_policy_document.firehose_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
- [aws_iam_policy_document.firehose_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
- [aws_iam_policy_document.stream_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
- [aws_kms_key.key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_key) (data source)
- [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) (data source)

## Required Inputs

The following input variables are required:

### <a name="input_kinesis_data_producers"></a> [kinesis\_data\_producers](#input\_kinesis\_data\_producers)

Description: Map of principals allowed to put records into the Kinesis stream

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

Type:

```hcl
object({
    aws       = optional(set(string))
    federated = optional(set(string))
  })
```

### <a name="input_log_group_name"></a> [log\_group\_name](#input\_log\_group\_name)

Description: The name of the log group in which to create the firehose logging stream

Type: `string`

### <a name="input_project_name"></a> [project\_name](#input\_project\_name)

Description: Name of the project this module is being included in, used when naming resourcces

Type: `string`

### <a name="input_s3_data_consumers"></a> [s3\_data\_consumers](#input\_s3\_data\_consumers)

Description: Map of principals allowed to read from the target s3 bucket

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

Type:

```hcl
object({
    aws       = optional(set(string))
    federated = optional(set(string))
  })
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_alarm_high_threshold"></a> [alarm\_high\_threshold](#input\_alarm\_high\_threshold)

Description: The number of incoming records during a 5 minute period above which which the alarm should trigger

Type: `number`

Default: `1000`

### <a name="input_alarm_low_threshold"></a> [alarm\_low\_threshold](#input\_alarm\_low\_threshold)

Description: The number of incoming records during a 5 minute period below which which the alarm should trigger

Type: `number`

Default: `50`

### <a name="input_alarm_subscription_email_addresses"></a> [alarm\_subscription\_email\_addresses](#input\_alarm\_subscription\_email\_addresses)

Description: The set of email addresses to subscribe to alarm notifications  
Each will receive an initial email asking to confirm the subscription

Type: `set(string)`

Default: `[]`

### <a name="input_buffering_interval"></a> [buffering\_interval](#input\_buffering\_interval)

Description: Buffer incoming data for the specified period of time, in seconds, before delivering it to the destination  
Note that both this and `buffering_size` may be set

Type: `number`

Default: `400`

### <a name="input_buffering_size"></a> [buffering\_size](#input\_buffering\_size)

Description: Buffer incoming data to the specified size, in MBs, before delivering it to the destination  
Note that both this and `buffering_interval` may be set

Type: `number`

Default: `10`

### <a name="input_data_transformation_lambda_arn"></a> [data\_transformation\_lambda\_arn](#input\_data\_transformation\_lambda\_arn)

Description: The ARN of a lambda to use if data transformation in FireHose is desired  
To control which revision is executed, ensure you specify it in the ARN

Type: `string`

Default: `""`

### <a name="input_dynamic_partitioning_config"></a> [dynamic\_partitioning\_config](#input\_dynamic\_partitioning\_config)

Description: Supply a configuration object if you wish to use dynamic partitioning  
If this is true, you must provide the jq\_metadata\_query, and s3\_dynamic\_prefix, s3\_error\_prefix  
See the AWS blog [post](https://aws.amazon.com/blogs/big-data/kinesis-data-firehose-now-supports-dynamic-partitioning-to-amazon-s3/) and [documentation](https://docs.aws.amazon.com/firehose/latest/dev/dynamic-partitioning.html) for more information

Of particular note:
> When you use the Data Transformation feature in Firehose, the deaggregation will be applied before the Data Transformation.
> Data coming into Firehose will be processed in the following order: Deaggregation → Data Transformation via Lambda → Partitioning Keys.

Type:

```hcl
object({
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
```

Default: `{}`

### <a name="input_enable_dynamic_partitioning"></a> [enable\_dynamic\_partitioning](#input\_enable\_dynamic\_partitioning)

Description: Whether to enable Firehose's dynamic partitioning
`dynamic_partitioning_config` must be supplied if `true`

|    Changing this after creation will force destruction and recreation of the Firehose stream!    |
|--------------------------------------------------------------------------------------------------|

Type: `bool`

Default: `false`

### <a name="input_env"></a> [env](#input\_env)

Description: Current deployment environment name ('Dev', 'Test', or 'Prod')

Type: `string`

Default: `"Dev"`

### <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id)

Description: The KMS key to use for encryption  
Note that this is required if either `use_kms_for_kinesis` or `use_kms_for_s3` are true  
Note also that the key policy will need to permit the firehose role `firehose_role_arn` to do certain actions:
* `kms:Decrypt` if used for Kinesis
* `kms:GenerateDataKey` if used for S3

Type: `string`

Default: `""`

### <a name="input_retention_period"></a> [retention\_period](#input\_retention\_period)

Description: The number of hours records remain accessible in the Kinesis stream

Type: `number`

Default: `24`

### <a name="input_shard_count"></a> [shard\_count](#input\_shard\_count)

Description: The number of shards that the Kinesis stream will use, ignored if stream\_mode is 'ON\_DEMAND'

Type: `number`

Default: `1`

### <a name="input_stream_mode"></a> [stream\_mode](#input\_stream\_mode)

Description: The capacity mode for the Kinesis stream ('PROVISIONED', or 'ON\_DEMAND')

Type: `string`

Default: `"ON_DEMAND"`

### <a name="input_use_kms_for_kinesis"></a> [use\_kms\_for\_kinesis](#input\_use\_kms\_for\_kinesis)

Description: Use KMS key provided in `kms_key_id` for encryption of data in kinesis

Type: `bool`

Default: `false`

### <a name="input_use_kms_for_s3"></a> [use\_kms\_for\_s3](#input\_use\_kms\_for\_s3)

Description: Use KMS key provided in `kms_key_id` for S3 encryption (This is required for cross-account access)

Type: `bool`

Default: `false`

## Outputs

The following outputs are exported:

### <a name="output_affiliate_kinesis_stream_arn"></a> [affiliate\_kinesis\_stream\_arn](#output\_affiliate\_kinesis\_stream\_arn)

Description: The ARN of the Kinesis stream accepting source input for the analytics pipeline.  
This will be needed to provide that appropriate permissions data producers' roles.

### <a name="output_cloudwatch_dashboard_url"></a> [cloudwatch\_dashboard\_url](#output\_cloudwatch\_dashboard\_url)

Description: Link to the created dashboard

### <a name="output_firehose_role_arn"></a> [firehose\_role\_arn](#output\_firehose\_role\_arn)

Description: The ARN of the role Firehose will use.  
This will be useful in resource policies such as:
* Data transformation Lambda
* KMS key policy

### <a name="output_target_s3_bucket_name"></a> [target\_s3\_bucket\_name](#output\_target\_s3\_bucket\_name)

Description: The S3 bucket to which Firehose will write output
<!-- END_TF_DOCS -->

# Future work
## Tidying
1. CI/CD for the module
2. Module publishing
3. Tool improvement
  1. Get linting, testing, formatting, etc. into a pre-commit hook
  2. Get tidiness tools working on examples as well
  3. Add Auto-versioning

## Functional Improvements
1. Clean up of the handling of the configuration for dynamic partitioning
2. Support for conversion of data formats and schema based on existing Glue data
3. Allow for more granular access control to the S3 bucket
4. Additional modularity

## Examples Improvements
1. Examples' module `source` should be updated to point to the source repo (to prevent dev confusion)
2. Examples should include additional comments
3. Additional examples, particularly around dynamic partitioning
4. Testing of the examples

## Test improvements
1. Switch over to using `python` `tftest`, rather than the built in framework
2. Add tests that exercise more functionality, end to end
3. Add tests verifying compatibility with additional tool versions
