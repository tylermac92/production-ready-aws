variable "env" {
    description = "Environment name (dev/prod)"
    type        = string
}

variable "app_s3_bucket_name" {
    description = "S3 bucket name for app access"
    type        = string
}

variable "alb_s3_bucket_arn" {
    description = "S3 bucket ARN for ALB logs"
    type        = string
}