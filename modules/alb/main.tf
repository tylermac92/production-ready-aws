resource "random_pet" "suffix" {}

resource "aws_s3_bucket" "alb_logs" {
    bucket        = "${var.env}-alb-logs-${random_pet.suffix.id}"
    force_destroy = true

    lifecycle_rule { enabled = true }

    tags = { Name = "${var.env}-alb-logs" }
}

resource "aws_s3_bucket_public_access_block" "block" {
    bucket                  = aws_s3_bucket.alb_logs.id
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

data "aws_elb_service_account" "this" {}

resource "aws_s3_bucket_policy" "alb_log_policy" {
    bucket = aws_s3_bucket.alb_logs.id
    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [{
            Sid = "AWSLogDeliveryWrite",
            Effect = "Allow",
            Principal = { AWS = data.aws_elb_service_account.this.arn },
            Action = "s3:PutObject",
            Resource = "${aws_s3_bucket.alb_logs.arn}/*"
        }]
    })
}

resource "aws_security_group" "alb_sg" {
    name = "${var.env}-alb-sg"
    vpc_id = var.vpc_id

    ingress { 
        from_port   = 80 
        to_port     = 80 
        protocol    = "tcp" 
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0  
        to_port     = 0  
        protocol    = "-1"  
        cidr_blocks = ["0.0.0.0/0"] 
    }

    tags = { Name = "${var.env}-alb-sg" }
}

resource "aws_lb" "this" {
    name                       = "${var.env}-alb"
    load_balancer_type         = "application"
    security_groups            = [aws_security_group.alb_sg.id]
    subnets                    = var.public_subnet_ids
    enable_deletion_protection = false

    access_logs {
        bucket  = aws_s3_bucket.alb_logs.id
        prefix  = "access-logs"
        enabled = true
    }

    tags = { Environment = var.env }
}

resource "aws_lb_target_group" "app_tg" {
    name        = "${var.env}-tg"
    port        = var.app_port
    protocol    = "HTTP"
    vpc_id      = var.vpc_id
    target_type = "instance"
    health_check {
        path                = "/"
        matcher             = "200"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
    }
}

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.this.arn
    port              = 80
    protocol          = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.app_tg.arn
    }
}