data "aws_ami" "amazon_linux" {
    most_recent = true
    owners      = ["amazon"]
    filter {
        name   = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
}

resource "aws_security_group" "app_sg" {
    name        = "${var.env}-app-sg"
    description = "Allow HTTP from ALB only"
    vpc_id      = var.vpc_id

    ingress {
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
        security_groups = [var.alb_security_group_id]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = { Name = "${var.env}-app-sg" }
}

resource "aws_launch_template" "app_lt" {
    name_prefix = "${var.env}-app-lt-"
    image_id = data.aws_ami.amazon_linux.id
    instance_type = "t3.micro"
    iam_instance_profile {
        name = var.instance_profile
    }
    security_group_names = []
    network_interfaces {
        security_groups = [aws_security_group.app_sg.id]
        associate_public_ip_address = false
    }


    user_data = base64encode(<<EOF
#!/bin/bash
yum update -y
yum install -y httpd
systemctl enable httpd
systemctl start httpd
echo "<h1>Hello from ${var.env}!</h1>" > /var/www/html/index.html
EOF
    )
}

resource "aws_autoscaling_group" "app_asg" {
    name                = "${var.env}-app-asg"
    desired_capacity    = 2
    max_size            = 3
    min_size            = 1
    vpc_zone_identifier = var.private_subnet_ids
    launch_template {
        id      = aws_launch_template.app_lt.id
        version = "$Latest"
    }

    tag {
        key                 = "Name"
        value               = "${var.env}-app-instance"
        propagate_at_launch = true
    }

    lifecycle {
        create_before_destroy = true
    }
}