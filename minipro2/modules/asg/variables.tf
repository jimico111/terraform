variable "name" {
  description = "Name of ASG"
  type = string
}

variable "vpc_id" {
  description = "Id of VPC"
  type = string
}

variable "vpc_zone_identifier" {
  description = "List of subnet IDs to launch resources in"
  type = list(string)
}

variable "key_name" {
  description = "Name of key pair"
  type = string
}

variable "target_group_arns" {
  description = "Target group arns for ASG"
  type = list(string)
}

variable "db_username" {
  description = "Username for Database"
  type = string
}

variable "db_password" {
  description = "Password for Database"
  type = string
}

variable "db_address" {
  description = "Address of Database"
  type = string
}