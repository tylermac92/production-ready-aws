output "alb_dns_name"            { value = aws_lb.this.dns_name }
output "alb_security_group_id"   { value = aws_security_group.alb_sg.id }
output "target_group_arn"        { value = aws_lb_target_group.app_tg.arn }
output "log_bucket_name"         { value = aws_s3_bucket.alb_logs.bucket }
output "log_bucket_arn"          { value = aws_s3_bucket.alb_logs.arn }
