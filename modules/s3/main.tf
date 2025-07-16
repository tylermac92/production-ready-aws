resource "random_pet" "suffix" {}

resource "aws_s3_bucket" "assets" {
  bucket        = "${var.env}-app-bucket-${random_pet.suffix.id}"
  force_destroy = true

  tags = {
    Name        = "${var.env}-app-bucket"
    Environment = var.env
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.assets.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.assets.id

  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.assets.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "logs_lifecycle" {
  bucket = aws_s3_bucket.assets.id

  rule {
    id     = "delete-logs"
    status = "Enabled"

    filter {
      prefix = "logs/"
    }

    expiration {
      days = 7
    }
  }
}

resource "aws_s3_bucket_policy" "allow_app_role" {
  bucket = aws_s3_bucket.assets.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid: "AllowAppWriteAccess",
        Effect: "Allow",
        Principal: {
          AWS: var.iam_role_arn
        },
        Action: [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource: [
          "${aws_s3_bucket.assets.arn}",
          "${aws_s3_bucket.assets.arn}/*"
        ]
      },
      {
        Sid: "PublicReadForWebsite",
        Effect: "Allow",
        Principal: "*",
        Action: ["s3:GetObject"],
        Resource: "${aws_s3_bucket.assets.arn}/*"
      }
    ]
  })
}
