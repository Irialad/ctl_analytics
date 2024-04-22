terraform {
  required_version = ">= 1.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.45.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.1"
    }
  }
}

data "aws_region" "current" {}

data "aws_kms_key" "key" {
  count = var.use_kms_for_kinesis || var.use_kms_for_s3 ? 1 : 0

  key_id = var.kms_key_id
}
