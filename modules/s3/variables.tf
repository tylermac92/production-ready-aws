variable "env" {
  type        = string
  description = "Environment name (dev or prod)"
}

variable "iam_role_arn" {
  type        = string
  description = "IAM role ARN that should be granted write access to the bucket"
}
