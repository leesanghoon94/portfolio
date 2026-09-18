resource "aws_vpc" "my-vpc" {
  cidr_block = "10.1.0.0/16"
  enable_dns_hostnames = true

  tags = {
    "Name" = "my-vpc" 
  }
}

resource "aws_subnet" "my-public-subnet-a" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.1.1.0/26"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "my-public-subnet-a"
  }
}
resource "aws_subnet" "my-public-subnet-c" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.1.1.64/26"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "my-public-subnet-c"
  }
}

resource "aws_subnet" "my-private-subnet-app-a" {
  vpc_id = aws_vpc.my-vpc.id
  cidr_block = "10.1.1.128/27"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "my-private-subnet-app-a"
  }
}
resource "aws_subnet" "my-private-subnet-app-c" {
  vpc_id = aws_vpc.my-vpc.id
  cidr_block = "10.1.1.160/27"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "my-private-subnet-app-c"
  }
}

resource "aws_subnet" "my-private-subnet-db-a" {
  vpc_id = aws_vpc.my-vpc.id
  cidr_block = "10.1.1.192/27"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "my-private-subnet-db-a"
  }
}


resource "aws_subnet" "my_private_subnet_db_c" {
  vpc_id = aws_vpc.my-vpc.id
  cidr_block = "10.1.1.224/27"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "my_private_subnet_db_c"
  }
}


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
  subnet_id     = aws_subnet.my-public-subnet-a.id

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

resource "aws_route_table_association" "public-a" {
  subnet_id      = aws_subnet.my-public-subnet-a.id
  route_table_id = aws_route_table.public-route.id
}
resource "aws_route_table_association" "public-c" {
  subnet_id      = aws_subnet.my-public-subnet-c.id
  route_table_id = aws_route_table.public-route.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.my-private-subnet-app-a.id
  route_table_id = aws_route_table.private-route.id
}

resource "aws_route_table_association" "private_app_c" {
  subnet_id      = aws_subnet.my-private-subnet-app-c.id
  route_table_id = aws_route_table.private-route.id
}

resource "aws_route_table_association" "private_db_a" {
  subnet_id      = aws_subnet.my-private-subnet-db-a.id
  route_table_id = aws_route_table.private-route.id
}

resource "aws_route_table_association" "private_db_c" {
  subnet_id      = aws_subnet.my_private_subnet_db_c.id
  route_table_id = aws_route_table.private-route.id
}


# module "vpc" {
#   source = "terraform-aws-modules/vpc/aws"

#   name = "my-vpc"
#   cidr = "192.168.0.0/24"

#   azs             = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
#   private_subnets = ["192.0.1.0/25", "192.0.2.0/25", "192.0.3.0/25"]
#   public_subnets  = ["192.0.101.0/25", "192.0.102.0/25", "192.0.103.0/25"]

#   enable_nat_gateway = true
#   enable_vpn_gateway = true

#   tags = {
#     Terraform = "true"
#     Environment = "dev"
#   }
# }