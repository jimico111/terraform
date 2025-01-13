provider "aws" {
  region = "us-east-2"
}

# vpc 생성
resource "aws_vpc" "myVPC" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  enable_dns_hostnames = true

  tags = {
    Name = "myVPC"
  }
}

# Internet Gateway 생성 & VPC 연결
resource "aws_internet_gateway" "myIGW" {
  vpc_id = aws_vpc.myVPC.id

  tags = {
    Name = "myIGW"
  }
}

# Public subnet 생성
resource "aws_subnet" "myPubSubnet" {
  vpc_id     = aws_vpc.myVPC.id
  cidr_block = "10.0.0.0/24"

  map_public_ip_on_launch = true

  tags = {
    Name = "myPubSubnet"
  }
}

# Public Routing Table 생성 & Public Subnet에 연결
resource "aws_route_table" "myPubRT" {
  vpc_id = aws_vpc.myVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myIGW.id
  }

  tags = {
    Name = "myPubRT"
  }
}

resource "aws_route_table_association" "myPubRTAssoc" {
  subnet_id      = aws_subnet.myPubSubnet.id
  route_table_id = aws_route_table.myPubRT.id
}

# SG 생성
resource "aws_security_group" "allow_http" {
  name = "allow_http"
  description = "Allow HTTP inbound traffic and all outbound traffic"
  vpc_id = aws_vpc.myVPC.id

  tags = {
    Name = "allow_http"
  }
}

# SG Rule 생성
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.allow_http.id
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 80
  ip_protocol = "tcp"
  to_port = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.allow_http.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}

# EC2 생성
resource "aws_instance" "myEC2" {
  ami           = "ami-0d7ae6a161c5c4239"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.myPubSubnet.id

  vpc_security_group_ids = [aws_security_group.allow_http.id]

  user_data_replace_on_change = true
  user_data = <<-EOF
    #!/bin/bash
    yum install -y httpd
    echo "Hello World" > /var/www/html/index.html
    systemctl enable --now httpd
    EOF

  tags = {
    Name = "myEC2"
  }

  depends_on = [aws_internet_gateway.myIGW]
}
