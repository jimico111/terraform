provider "aws" {
    region = "us-east-2"
}

# 1) VPC 생성
# 2) IGW 생성 및 붙이기
# 3) Routing Table 생성 + Route 정보 등록
# 4) Public Subnet 생성 + 연결
# * MyPublicSN1
# * MyPublicSN2
# 5) Security Group 생성
# 6) EC2 생성
# * MyEC21
# * MyEC22
# 7) EC2에 EIP 할당
# 8) ALB Target Group 생성 및 EC2 인스턴스 연결
# 9) ALB 생성 & Listener 생성 & Listener 규칙 생성



# 1) VPC 생성
# Resource: aws_vpc
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "myVPC" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  
  tags = {
    Name = "myVPC"
  }
}

# 2) IGW 생성 및 붙이기
# Resource: aws_internet_gateway
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "myIGW" {
  vpc_id = aws_vpc.myVPC.id

  tags = {
    Name = "myIGW"
  }
}


# 3) Routing Table 생성 + Route 정보 등록
# Resource: aws_route_table
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
resource "aws_route_table" "myPublicRT" {
  vpc_id = aws_vpc.myVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myIGW.id
  }


  tags = {
    Name = "myPublicRT"
  }
}
# 4) Public Subnet 생성 + 연결
# Resource: aws_subnet
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
# * MyPublicSN1
resource "aws_subnet" "MyPublicSN1" {
  vpc_id     = aws_vpc.myVPC.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "MyPublicSN1"
  }
}


resource "aws_route_table_association" "myPubRT1" {
  subnet_id      = aws_subnet.MyPublicSN1.id
  route_table_id = aws_route_table.myPublicRT.id
}

# * MyPublicSN2
resource "aws_subnet" "MyPublicSN2" {
  vpc_id     = aws_vpc.myVPC.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "MyPublicSN2"
  }
}

resource "aws_route_table_association" "myPubRT2" {
  subnet_id      = aws_subnet.MyPublicSN2.id
  route_table_id = aws_route_table.myPublicRT.id
}


# 5) Security Group 생성
# Resource: aws_security_group
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "mySG" {
  name        = "mySG"
  description = "Allow 80, 8080, 22 inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.myVPC.id

  tags = {
    Name = "mySG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_80" {
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_8080" {
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}


resource "aws_vpc_security_group_ingress_rule" "allow_22" {
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}


resource "aws_vpc_security_group_egress_rule" "allow_all" {
  security_group_id = aws_security_group.mySG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}



# 6) EC2 생성
# Resource: aws_instance
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
# * MyEC21
resource "aws_instance" "MyEC21" {
  ami           = "ami-0cb91c7de36eed2cb"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.MyPublicSN1.id
  vpc_security_group_ids = [aws_security_group.mySG.id]
  user_data_replace_on_change = true
  user_data = <<-EOF
    #!/bin/bash
        hostname EC2-1
        yum install httpd -y
        service httpd start
        chkconfig httpd on
        echo "<h1>CloudNet@ EC2-1 Web Server</h1>" > /var/www/html/index.html
    EOF

  tags = {
    Name = "MyEC21"
  }
}



# * MyEC22
resource "aws_instance" "MyEC22" {
  ami           = "ami-0cb91c7de36eed2cb"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.MyPublicSN2.id
  vpc_security_group_ids = [aws_security_group.mySG.id]
  user_data_replace_on_change = true
  user_data = <<-EOF
   #!/bin/bash
        hostname ELB-EC2-2
        yum install httpd -y
        service httpd start
        chkconfig httpd on
        echo "<h1>CloudNet@ EC2-2 Web Server</h1>" > /var/www/html/index.html
    EOF

  tags = {
    Name = "MyEC22"
  }
}

# 7) EC2에 EIP 할당
# Resource: aws_eip
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip
resource "aws_eip" "MyEC21_eip" {
  instance = aws_instance.MyEC21.id
  domain   = "vpc"
}

resource "aws_eip" "MyEC22_eip" {
  instance = aws_instance.MyEC22.id
  domain   = "vpc"
}


# 8) ALB Target Group 생성 및 EC2 인스턴스 연결
# Resource: aws_lb_target_group , Resource: aws_lb_target_group_attachment
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment
resource "aws_lb_target_group" "myalb-tg" {
  name     = "myalb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myVPC.id
}

resource "aws_lb_target_group_attachment" "tg_attachment-ec21" {
  target_group_arn = aws_lb_target_group.myalb-tg.id
  target_id        = aws_instance.MyEC21.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "tg_attachment-ec22" {
  target_group_arn = aws_lb_target_group.myalb-tg.id
  target_id        = aws_instance.MyEC22.id
  port             = 80
}

# 9) ALB 생성 & Listener 생성 & Listener 규칙 생성
# Resource: aws_lb , Resource: aws_lb_listener
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener
resource "aws_lb" "my_alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.mySG.id]
  subnets            = [aws_subnet.MyPublicSN1.id, aws_subnet.MyPublicSN2.id]

  enable_deletion_protection = false

  tags = {
    Name = "my-alb"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.myalb-tg.arn
  }
}

