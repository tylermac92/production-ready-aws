provider "aws" {
    region = "us-east-1"
}

resource "aws_s3_bucket" "tf_state" {
    bucket        = "multi-tier-prod-infra-tf-state"
    force_destroy = true

    versioning {
        enabled = true
    }

    tags = {
        Name        = "Terraform State Bucket"
        Environment = "Shared"
    }
}

resource "aws_s3_bucket_public_access_block" "block" {
    bucket = aws_s3_bucket.tf_state.id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

resource "aws_dynamodb_table" "tf_lock" {
    name         = "multi-tier-prod-infra-lock-table"
    billing_mode = "PAY_PER_REQUEST"
    hash_key     = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }

    tags = {
        Name        = "Terraform Lock Table"
        Environment = "Shared"
    }
}