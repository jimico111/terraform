variable "region" {
    default = "us-east-2"
    description = "Default Region"
    type = string
  
}

variable "web_port" {
    default = 80
  
}

variable "amazon" {
    default = "137112412989"
  
}

variable "min_instance" {
    default = 2
  
}

variable "max_instance" {
    default = 10
  
}