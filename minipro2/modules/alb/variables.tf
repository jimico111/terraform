variable "name" {
  description = "Name of ALB"
  type = string
}

variable "vpc_id" {
  description = "Id of VPC"
  type = string
}

variable "subnets" {
  description = "List of Subnet ids"
  type = list(string)
}