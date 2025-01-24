variable "db_username" {
  description = "Username of DB"
  type = string
  sensitive = true
}

variable "db_password" {
  description = "Password of DB"
  type = string
  sensitive = true
}

variable "key_name" {
  description = "Name of Key already uploaded in AWS"
  type        = string
}