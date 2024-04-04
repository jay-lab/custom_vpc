variable "image_id" {
  type = string
  default = ""
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}

variable "server_port" {
  type = number
  default = 80
}

variable "instance_security_group_name" {
  type = string
  default = "allow_http_ssh_instance"
}