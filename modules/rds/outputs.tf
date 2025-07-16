output "db_endpoint" { 
    value = aws_db_instance.this.endpoint 
}

output "secret_arn" { 
    value = aws_secretsmanager_secret.db.arn 
}

output "db_security_group" { 
    value = aws_security_group.db_sg.id 
}
