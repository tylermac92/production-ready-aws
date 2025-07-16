output "bucket_name" {
  value = aws_s3_bucket.assets.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.assets.arn
}

output "website_endpoint" {
  value = aws_s3_bucket.assets.website_endpoint
}
