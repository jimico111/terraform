#
# terraform & provider 설정
#

terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
      }
    }
}


provider "aws" {
    region = var.region
  
}

# 작업절차
# 1. ASG 생성
# 1) 보안그룹생성
# 2) 시작 템플릿 생성
# 3) autoscaling group 생성

# 2. ALB 생성
# 1) 보안그룹생성
# 2) LB target group 생성
# 3) LB 구성
# 4) LB listener 구성
# 5) LB listener rule 구성

#########################
# 0. Basic Infrastructure
# Data Source: aws_vpc
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
data "aws_vpc" "default" {
    default = true
}


# Data Source: aws_subnets
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
#############################
# 1. ASG 생성
############################
# 1) 보안 그룹 생성
# Data Source: aws_security_group
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "myasg_sg" {
  name        = "myasg_sg"
  description = "Allow SSH,HTTP inbound traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "myasg_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.myasg_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.myasg_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = var.web_port
  ip_protocol       = "tcp"
  to_port           = var.web_port
}


resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.myasg_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}




# 2) 시작 템플릿/시작 구성 생성
# Data Source:  aws_ami
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami
data "aws_ami" "amazon_2023_ami" {
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
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

# Data Source: launch_template
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template
resource "aws_launch_template" "myasg_template" {
  name = "myasg_template"
   image_id = data.aws_ami.amazon_2023_ami.id
   instance_type = "t2.micro"
   vpc_security_group_ids = [aws_security_group.myasg_sg.id]
   user_data = filebase64("./userdata.sh")


   lifecycle {
    create_before_destroy = true
  }
}


# 3) autoscaling group 생성
# Data Source: aws_autoscaling_group
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group
resource "aws_autoscaling_group" "myasg" {
  name                      = "myasg"
  vpc_zone_identifier = data.aws_subnets.default.ids
  launch_template {
    id      = aws_launch_template.myasg_template.id
  }

  ##################### 주의 #########################
  # load_balancers
  target_group_arns = [aws_lb_target_group.mylb-tg.arn]
  depends_on = [aws_lb_target_group.mylb-tg]

  min_size                  = var.min_instance
  max_size                  = var.max_instance
  

  tag {
    key                 = "Name"
    value               = "myasg"
    propagate_at_launch = true
  }
}

#####################################
# 2. ALB 생성
#####################################
# 1) 보안그룹생성
# 2) LB target group 생성
# Data Source: aws_lb_target_group
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
resource "aws_lb_target_group" "mylb-tg" {
  name     = "mylb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
}








# 3) LB 구성
# Data Source: aws_lb
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
resource "aws_lb" "mylb" {
  name               = "mylb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.myasg_sg.id]
  subnets            = data.aws_subnets.default.ids
}
# 4) LB listener 구성
# Data Source: aws_lb_listener
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listene

resource "aws_lb_listener" "mylb_listener" {
  load_balancer_arn = aws_lb.mylb.arn
  port              = "${var.web_port}"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404 Not Found"
      status_code  = "404"
    }
  }
}
# 5) LB listener rule 구성
# Data Source: aws_lb_listener_rule
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule

resource "aws_lb_listener_rule" "mylb_listener_rule" {
  listener_arn = aws_lb_listener.mylb_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mylb-tg.arn
  }

  condition {
    path_pattern {
      values = ["/index.html"]
    }
  }
}