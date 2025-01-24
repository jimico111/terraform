variable "name" {
  description = "Name of VPC"
  type        = string
}

variable "cidr" {
  description = "CIDR of VPC"
  type        = string
}

variable "azs" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
}

variable "public_subnets" {
  description = "A list of CIDR blocks of public subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "A list of CIDR blocks of private subnets"
  type        = list(string)
}