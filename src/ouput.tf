output "public_instance_ip" {
  description = "The public IP address of the public web server"
  value       = "${aws_instance.web_pub.public_ip}:${var.server_port}"
}