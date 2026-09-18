terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.39.1"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

data "aws_availability_zones" "available" {
  exclude_names = ["ap-northeast-2b"]
}

resource "aws_vpc" "my-vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    "Name" = "my-vpc" 
  }
}
// 서브넷
resource "aws_subnet" "public" {
  count = var.az_count
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr_block,8,2+count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = {
    Name = "publicSubnet_${count.index}"
  }
}

resource "aws_subnet" "private_app" {
  count = var.az_count
  vpc_id = aws_vpc.my-vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr_block,8, 4+count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "privateSubnet_app_${count.index}"
  }
}

resource "aws_subnet" "private_db" {
  count = var.az_count
  vpc_id = aws_vpc.my-vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr_block,8, 6+count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "privateSubnet_db_${count.index}"
  }
}
// 라우트테이블
resource "aws_route_table" "public-route" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "10.1.0.0/16"
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route"
  }
}

resource "aws_route_table" "private-route" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "10.1.0.0/16"
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw.id
  }

  tags = {
    Name = "private-route"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "igw"
  }
}

resource "aws_nat_gateway" "natgw" {
  
  allocation_id = aws_eip.elb.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_eip" "elb" {
  
  domain   = "vpc"

  depends_on = [ aws_internet_gateway.igw ]
}

resource "aws_route_table_association" "public" {
  count = var.az_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public-route.id
}

resource "aws_route_table_association" "private" {
  count = var.az_count
  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private-route.id
}

resource "aws_route_table_association" "private_db" {
  count = var.az_count
  subnet_id      = aws_subnet.private_db[count.index].id
  route_table_id = aws_route_table.private-route.id
}