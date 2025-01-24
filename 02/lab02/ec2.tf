# provider - Region 선택
provider "aws" {
    region = "us-east-2"
  
}


# EC2 인스턴스를 위한 데이터 선택
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }


  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}



# EC2 인스턴스를 위한 Security Group 생성

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic and all outbound traffic"

  tags = {
    Name = "allow_ssh"
  }
}

# Security Group ingress
# ssh(22/tcp) 허용
resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# Security Group egress
# -모두 허용
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}

# Keypair 생성은 되어 있다고 가정
# - (키페어 이름): mykeypair 2


# EC2 생성
resource "aws_instance" "myEC2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  key_name = "mykeypair2"
  security_groups = [aws_security_group.allow_ssh.name]


  tags = {
    Name = "myEC2-test"
  }
}

# Output 변수 - AMI ID 출력
output "ami_id" {
    value = aws_instance.myEC2.ami
    description = "Ubuntu 24.04 LTS AMI ID"
}