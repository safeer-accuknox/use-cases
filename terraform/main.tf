terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.64.0"  
    }
  }
}

provider "aws" {
  alias  = "default"
  region = "us-east-1"
}

resource "aws_s3_bucket" "this" {
  bucket = "my-unique-bucket-name"
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls = false
  ignore_public_acls = false
  block_public_policy = false
  restrict_public_buckets = false
}
