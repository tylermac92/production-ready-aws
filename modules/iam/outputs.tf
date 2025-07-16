output "ec2_role_name" {
    value = aws_iam_role.ec2_app.name
}

output "ec2_instance_profile" {
    value = aws_iam_instance_profile.ec2_instance_profile.name
}

output "alb_log_role" {
    value = aws_iam_role.alb_log_role.name
}