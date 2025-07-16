data "aws_availability_zones" "azs" {}

resource "random_password" "db" {
    length = 20
    special = false
}

resource "aws_secretsmanager_secret" "db" {
    name = "${var.env}-rds-credentials"
}

resource "aws_secretsmanager_secret_version" "db" {
    secret_id = aws_secretsmanager_secret.db.id
    secret_string = jsonencode({
        username = var.db_username,
        password = random_password.db.result
    })
}

resource "aws_security_group" "db_sg" {
    name   = "${var.env}-rds-sg"
    vpc_id = var.vpc_id

    ingress {
        description = "Allow Postgres from app tier"
        from_port       = 5432
        to_port         = 5432
        protocol        = "tcp"
        security_groups = [var.app_security_group_id]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_db_subnet_group" "this" {
    name = "${var.env}-rds-subnet-group"
    subnet_ids = var.private_subnet_ids
}

resource "aws_db_instance" "this" {
    identifier           = "${var.env}-postgres"
    engine               = "postgres"
    engine_version       = "15"
    instance_class       = var.instance_class
    allocated_storage    = var.storage_gb
    storage_type         = "gp3"
    multi_az             = true
    db_subnet_group_name = aws_db_subnet_group.this.name

    username = var.db_username
    password = random_password.db.result
    db_name  = var.db_name

    backup_retention_period = var.backup_retention
    deletion_protection     = false
    skip_final_snapshot     = true

    vpc_security_group_ids = [aws_security_group.db_sg.id]

    tags = {
        Environment = var.env
    }
}