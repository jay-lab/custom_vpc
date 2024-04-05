# VPC 생성
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  #  instance_tenancy = "default" # Default is default
  #  enable_dns_support = true # Defaults true.
  enable_dns_hostnames = true # Defaults false
  tags = {
    Name = "tf-vpc"
  }
}
# enable_dns_hostnames 옵션이 true로 설정되면, AWS는 VPC 내의 인스턴스에 대해 DNS 호스트 이름을 자동으로 할당하고,
# 이를 통해 인스턴스를 DNS 이름으로 통신할 수 있게 합니다.
# 예를 들어, EC2 인스턴스나 다른 서비스에 연결할 때 IP 주소 대신 DNS 이름을 사용할 수 있습니다.
# 이는 인프라를 더 쉽게 관리하고, 인스턴스 간의 통신을 더 간단하게 만들어 줍니다.

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "tf-igw"
  }
}

#########################################################################################################
# 퍼블릭 리소스
#########################################################################################################
# 퍼블릭 서브넷 a
resource "aws_subnet" "pub_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = true # 서브넷에 생성되는 인스턴스가 자동적으로 퍼블릭 IPv4 주소를 할당받을수 있도록 하는 옵션
  tags = {
    Name = "tf-subnet-public1-ap-northeast-2a"
  }
}

# 퍼블릭 서브넷 c
resource "aws_subnet" "pub_c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-northeast-2c"
  map_public_ip_on_launch = true # 서브넷에 생성되는 인스턴스가 자동적으로 퍼블릭 IPv4 주소를 할당받을수 있도록 하는 옵션
  tags = {
    Name = "tf-subnet-public2-ap-northeast-2c"
  }
}

# 퍼블릭 라우팅 테이블
resource "aws_route_table" "pub" {
  vpc_id = aws_vpc.main.id

  #  route {
  #    cidr_block = "10.0.0.0/16"
  #    gateway_id = "local"
  #  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "tf-rtb-public"
  }
}

# 퍼블릭 라우팅 테이블 <-> 퍼블릭 서브넷 연결 구성
resource "aws_route_table_association" "pub_a" {
  subnet_id      = aws_subnet.pub_a.id
  route_table_id = aws_route_table.pub.id
}

resource "aws_route_table_association" "pub_c" {
  subnet_id      = aws_subnet.pub_c.id
  route_table_id = aws_route_table.pub.id
}

#########################################################################################################
# 프라이빗 리소스
#########################################################################################################
# 프라이빗 서브넷 a
resource "aws_subnet" "pri_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-2a"
  #  map_public_ip_on_launch = true # 서브넷에 생성되는 인스턴스가 자동적으로 퍼블릭 IPv4 주소를 할당받을수 있도록 하는 옵션
  tags = {
    Name = "tf-subnet-private1-ap-northeast-2a"
  }
}

# 프라이빗 서브넷 c
resource "aws_subnet" "pri_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-northeast-2c"
  #  map_public_ip_on_launch = true # 서브넷에 생성되는 인스턴스가 자동적으로 퍼블릭 IPv4 주소를 할당받을수 있도록 하는 옵션
  tags = {
    Name = "tf-subnet-private2-ap-northeast-2c"
  }
}
# 프랴이빗 라우팅 테이블 a
resource "aws_route_table" "pri_a" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw_a.id
  }
  tags = {
    Name = "tf-rtb-private1-ap-northeast-2a"
  }
}

# 프랴이빗 라우팅 테이블 c
resource "aws_route_table" "pri_c" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw_a.id
  }
  tags = {
    Name = "tf-rtb-private2-ap-northeast-2c"
  }
}

# 프랴이빗 라우팅 테이블a <-> 프랴이빗 서브넷a 연결 구성
resource "aws_route_table_association" "pri_a" {
  subnet_id      = aws_subnet.pri_a.id
  route_table_id = aws_route_table.pri_a.id
}

# 프랴이빗 라우팅 테이블c <-> 프랴이빗 서브넷c 연결 구성
resource "aws_route_table_association" "pri_c" {
  subnet_id      = aws_subnet.pri_c.id
  route_table_id = aws_route_table.pri_c.id
}

resource "aws_eip" "pub_a" {
  domain = "vpc"

  tags = {
    Name = "tf-eip-ap-northeast-2a"
  }
}

resource "aws_nat_gateway" "gw_a" {
  allocation_id = aws_eip.pub_a.id
  subnet_id     = aws_subnet.pub_a.id
  tags = {
    Name : "tf-nat-public1-ap-northeast-2a"
  }
  depends_on = [aws_internet_gateway.gw] # 적절한 순서를 보장하려면 VPC에 대한 인터넷 게이트웨이에 명시적 종속성을 추가하는 것이 권장됨
}