provider "aws" {
  region = "${var.region}"
}

# EC2 SG
resource "aws_security_group" "ec2_SG" {
  vpc_id = "${var.vpc_id}"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "Custom"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = ["${aws_security_group.ALB_SG.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS SG
resource "aws_security_group" "RDS_SG" {
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = ["${aws_security_group.ec2_SG.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS Subnet group
resource "aws_db_subnet_group" "subnet_grp" {
  subnet_ids = ["${var.private-subnet-1}", "${var.private-subnet-2}"]
}

# RDS instance
resource "aws_db_instance" "App_DB" {
  allocated_storage      = 10
  engine                 = "postgres"
  engine_version         = "12.10"
  instance_class         = "${var.instance_class}"
  db_subnet_group_name   = "${aws_db_subnet_group.subnet_grp.id}"
  vpc_security_group_ids = ["${aws_security_group.RDS_SG.id}"]
  name                   = "${var.database_name}"
  username               = "${var.database_user}"
  password               = "${var.database_password}"
  skip_final_snapshot    = true
}

# EC2 userdata
data "template_file" "user_data" {
  template = "${file("${path.module}/user_data")}"

  vars = {
    db_username      = "${var.database_user}"
    db_user_password = "${var.database_password}"
    db_name          = "${var.database_name}"
    db_RDS           = "${aws_db_instance.App_DB.endpoint}"
  }
}

resource "aws_key_pair" "mykey-pair" {
  key_name   = "mykey-pair"
  public_key = "${file(var.PUBLIC_KEY_PATH)}"
}

# EC2 instance
resource "aws_instance" "App_EC2" {
  ami             = "${var.ami}"
  instance_type   = "${var.instance_type}"
  subnet_id       = "${var.private-subnet-app}"
  security_groups = ["${aws_security_group.ec2_SG.id}"]
  user_data       = "${data.template_file.user_data.rendered}"
  key_name        = "${aws_key_pair.mykey-pair.id}"

  depends_on = ["aws_db_instance.App_DB"]
}

# EC2 Elastic IP
resource "aws_eip" "eip" {
  instance = "${aws_instance.App_EC2.id}"
}

# ALB SG
resource "aws_security_group" "ALB_SG" {
  vpc_id = "${var.vpc_id}"

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Custom"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ALB
resource "aws_lb" "App-ALB" {
  name               = "App-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.ALB_SG.id}"]
  subnets            = ["${var.public-subnet-1}", "${var.public-subnet-2}"]
}

# ALB listener
resource "aws_alb_listener" "App-listener" {
  load_balancer_arn = "${aws_lb.App-ALB.arn}"
  port              = "80"
  protocol          = "HTTP"

  ssl_policy        = var.alb_ssl_policy
  certificate_arn   = var.alb_certificate_arn

  default_action {
    target_group_arn = "${aws_alb_target_group.App-tgtgrp.arn}"
    type             = "forward"
  }
}

resource "aws_alb_target_group" "App-tgtgrp" {
  name     = "${var.Appalb_targetgrp}"
  port     = 3000
  protocol = "HTTPS"
  vpc_id   = "${var.vpc_id}"

  health_check {
    protocol = "HTTPS"

    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3

    //path                = var.path
    interval = 30
    matcher  = "200"
  }
}

resource "aws_lb_target_group_attachment" "target_group_attach" {
  target_group_arn = "${aws_alb_target_group.App-tgtgrp.arn}"

  target_id = "${aws_instance.App_EC2.id}"
  port      = 3000
}

output "RDS-Endpoint" {
  value = "${aws_db_instance.App_DB.endpoint}"
}

output "Public IP" {
  value = "${aws_eip.eip.public_ip}"
}

output "Private ip" {
  value = ["${aws_instance.App_EC2.*.private_ip}"]
}

output "alb_arn" {
  value = ["${aws_lb.App-ALB.arn}"]
}

output "alb_dns_name" {
  value = ["${aws_lb.App-ALB.dns_name}"]
}
