resource "aws_iam_role" "ec2_app" {
    name = "${var.env}-ec2-app-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Principal = {
                Service = "ec2.amazonaws.com"
            }
            Action = "sts:AssumeRole"
        }]
    })

    tags = {
        Name = "${var.env}-ec2-app-role"
    }
}

resource "aws_iam_policy" "ec2_app_policy" {
    name = "${var.env}-ec2-app-policy"
    description = "Permissions for EC2 instances to access S3 and RDS"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "s3:GetObject",
                    "s3:PutObject",
                    "s3:ListBucket"
                ]
                Resource = [
                    "arn:aws:s3:::${var.app_s3_bucket_name}",
                    "arn:aws:s3:::${var.app_s3_bucket_name}/*"
                ]
            },
            {
                Effect = "Allow"
                Action = [
                    "rds:DescribeDBInstances",
                    "rds:Connect"
                ]
                Resource = "*"
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "ec2_app_attach" {
    role       = aws_iam_role.ec2_app.name
    policy_arn = aws_iam_policy.ec2_app_policy.arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
    name = "${var.env}-ec2-instance-profile"
    role = aws_iam_role.ec2_app.name
}

resource "aws_iam_role" "alb_log_role" {
    name = "${var.env}-alb-log-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Principal = {
                Service = "elasticloadbalancing.amazonaws.com"
            }
            Action = "sts:AssumeRole"
        }]
    })

    tags = {
        Name = "${var.env}-alb-log-role"
    }
}

resource "aws_iam_policy" "alb_log_policy" {
    name = "${var.env}-alb-log-policy"
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "s3:PutObject"
                ]
                Resource = "${var.alb_s3_bucket_arn}/*"
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "alb_log_attach" {
    role       = aws_iam_role.alb_log_role.name
    policy_arn = aws_iam_policy.alb_log_policy.arn
}