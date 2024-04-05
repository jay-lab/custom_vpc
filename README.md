### pem key  
```shell
cd ./keypair
ssh-keygen -m PEM -f mykey -N ""
chmod 400 mykey
```

### AMI data (Amazon Linux 2023)
```
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
```

### AMI data (Amazon Linux 2)
```
data "aws_ami" "amzlinux2" {
  most_recent = true
  owners  	= ["amazon"]
  name_regex  = "^amzn2-"

  filter {
	name   = "name"
	values = ["amzn2-ami-kernel-*-gp2"] // Kernel 5.10, SSD Volume Type
	#values = ["amzn2-ami-hvm-*-gp2"] // Kernel 4.14, SSD Volume Type
  }

  filter {
	name   = "architecture"
	values = ["x86_64"] 	#values = ["arm64"]
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

```

### EC2 웹 서버 설치 (userdata.tftpl)
```shell
ping 8.8.8.8
sudo yum -y install httpd
sudo systemctl enable httpd
sudo systemctl start httpd
echo '<html><h1>Hello My Private Subnet Linux Web Server!</h1></html>' | sudo tee -a /var/www/html/index.html

# "Amazon Linux 2"인 경우
    ID=$(curl 'http://169.254.169.254/latest/meta-data/instance-id')
    AZ=$(curl 'http://169.254.169.254/latest/meta-data/placement/availability-zone')

# "Amazon Linux 2023"인 경우
    TOKEN=$(curl --request PUT "http://169.254.169.254/latest/api/token" --header "X-aws-ec2-metadata-token-ttl-seconds: 3600")
    ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id --header "X-aws-ec2-metadata-token: $TOKEN")
    AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone --header "X-aws-ec2-metadata-token: $TOKEN")

printf "<h2>Instance-id: %s<br>Az: %s</h2>" $ID $AZ | sudo tee -a /var/www/html/index.html
```