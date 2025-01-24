provider "aws" {
  region = "us-east-2"
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket
resource "aws_s3_bucket" "terraform_state" {

  # 버킷 값은 유일한 이름을 지정해야 한다.
  bucket = "bucket-2001-1124"    # 자신의 생일로 bucket-년-월일로 지정한다.
  
  # https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle
  force_destroy = true

  # 코드 이력을 관리하기 위해 상태 파일의 버전 관리를 활성화 한다.
 

  # 서버 측 암호화를 활성화 한다.
  
  
  tags = {
    Name = "My bucket"
  }
}
# Resource: aws_s3_bucket_public_access_block
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block
resource "aws_s3_bucket_public_access_block" "terraform_state_acl" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table
resource "aws_dynamodb_table" "terraform_locks" {
  name           = "terraform-locks"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"    # 값은 S(string), N(number), B(binary) 중 하나이어야 한다.
  }
}
