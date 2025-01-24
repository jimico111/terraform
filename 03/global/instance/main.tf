
# https://developer.hashicorp.com/terraform/language/settings/backends/s3
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket         = "bucket-2001-1124"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true

  }
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "state-test-intance" {
  ami           = "ami-0fb653ca2d3203ac1"
  instance_type = "t2.micro"

  tags = {
    Name = "state-test-instance"
  }
}

