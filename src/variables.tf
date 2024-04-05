variable "image_id" {
  description = "The id of the machine image (AMI) to use for the server."
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "The Instance Type of the web server."
  type        = string
  default     = "t2.micro"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 80
}

variable "instance_security_group_name" {
  description = "The name of the security group for EC2 Instance"
  type        = string
  default     = "allow_http_ssh_instance"
}

variable "db_security_group_name" {
  description = "The name of the security group for RDB"
  type        = string
  default     = "allow_mysql_db"
}