provider "aws" {
  region = "us-east-2"
}

# SG 생성 - 8080
resource "aws_security_group" "allow_8080" {
  name = "allow_8080"
  description = "Allow 8080 port inbound traffic and all outbound traffic"

  tags = {
    Name = "my_allow_8080"
  }
}

# SG ingress rule
resource "aws_vpc_security_group_ingress_rule" "allow_8080_tls" {
  security_group_id = aws_security_group.allow_8080.id
  ip_protocol = "tcp"
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 8080
  to_port = 8080
}

# SG egress rule
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.allow_8080.id
  ip_protocol = "-1"
  cidr_ipv4 = "0.0.0.0/0"
}

# EC2 생성
resource "aws_instance" "myweb" {
  ami = "ami-036841078a4b68e14" # Ubuntu Server 24.04 LTS (HVM), SSD Volume Type
  instance_type = "t2.micro"
  vpc_security_group_ids = [ aws_security_group.allow_8080.id ]
  
  user_data_replace_on_change = true
  user_data = <<-EOF
    #!/bin/bash
    echo "Hello World" >> index.html
    nohup busybox httpd -f -p 8080 &
    EOF

  tags = {
    Name = "myweb"
  }
}
