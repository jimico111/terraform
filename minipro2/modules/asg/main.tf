# Security group for ASG 생성
resource "aws_security_group" "allow_asg" {
  name        = "${var.name}-allow_asg"
  description = "Allow some inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name}-allow_asg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_asg_http" {
  security_group_id = aws_security_group.allow_asg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_asg_ssh" {
  security_group_id = aws_security_group.allow_asg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_asg" {
  security_group_id = aws_security_group.allow_asg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Launch template 생성
resource "aws_launch_template" "launch_template" {
  name = "${var.name}-lt"

  image_id = data.aws_ami.al2023.id
  instance_type = "t2.micro"

  update_default_version = true

  key_name = var.key_name

  vpc_security_group_ids = [aws_security_group.allow_asg.id]

  user_data = base64encode(templatefile("${path.module}/userdata.tpl", {
    db_address = var.db_address,
    db_username = var.db_username,
    db_password = var.db_password
  }))

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.name}-instance"
    }
  }
}

# AMI data source
data "aws_ami" "al2023" {
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.6.*-kernel-6.1-x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Autoscaling group 생성
resource "aws_autoscaling_group" "asg" {
  name                      = var.name
  max_size                  = 2
  min_size                  = 2
  desired_capacity          = 2

  health_check_grace_period = 300
  health_check_type         = "ELB"

  force_delete              = true

  target_group_arns = var.target_group_arns

  vpc_zone_identifier       = var.vpc_zone_identifier

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }
}