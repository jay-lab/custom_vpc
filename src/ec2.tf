resource "aws_key_pair" "mykey" {
  key_name   = "mykey"
  public_key = file("./keypair/mykey.pub")
}

data "aws_ami" "amzlinux2023" {
  most_recent = true
  owners      = ["amazon"]
  name_regex  = "^al2023-"

  filter {
    name   = "name"
    values = ["al2023-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"] #values = ["arm64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "web" {
  name_prefix = "${var.instance_security_group_name}-"
  vpc_id      = aws_vpc.main.id
  description = "Allow HTTP inbound traffic"

  ingress {
    description = "HTTP from VPC"
    from_port   = var.server_port # 80
    to_port     = var.server_port # 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http_ssh_instance"
  }
}

resource "aws_instance" "web_pub" {
  ami                    = data.aws_ami.amzlinux2023.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.web.id]
  subnet_id              = aws_subnet.pub_c.id
  key_name               = aws_key_pair.mykey.key_name

  user_data = templatefile("userdata.tftpl", {
    port_number = var.server_port
  })
}