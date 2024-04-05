resource "aws_security_group" "db" {
  name_prefix = "allow_mysql"
  description = "Allow MYSQL inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "MYSQL from VPC"
    from_port   = 3306
    to_port     = 3306
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
    Name = var.db_security_group_name
  }
}

resource "aws_db_subnet_group" "tf-db" {
  name       = "tf-db subnet group"
  subnet_ids = [aws_subnet.pri_a.id, aws_subnet.pri_c.id]
  tags = {
    Name = "Terraform DB subnet group"
  }
}

resource "aws_db_instance" "tf-db" {
  identifier        = "tf-db"
  allocated_storage = 10
  engine            = "mysql"
  engine_version    = "5.7"
  instance_class    = "db.t3.micro"
  #  multi_az          = true
  db_name                = "tf"
  username               = "master"
  password               = "tf-password"
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.tf-db.name
  vpc_security_group_ids = [aws_security_group.db.id]
}