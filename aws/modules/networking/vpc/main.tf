//create a vpc with the given cidr block
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = {
    Name = "${var.environment}-vpc"
    Environment = var.environment
  }
}

//create a public subnet in the vpc
resource "aws_subnet" "public" {
    vpc_id = aws_vpc.main.id
    count = length(var.availability_zone)
    cidr_block = var.public_subnet_cidr[count.index]
    availability_zone = var.availability_zone[count.index]
    map_public_ip_on_launch = true

    tags = {
      Name = "${var.environment}-public-subnet-${count.index + 1}"
      Environment = var.environment
      "kubernetes.io/role/elb" = "1"
    }
}

//create an internet gateway for the vpc
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-igw"
    Environment = var.environment
  }
}

//create a route table for the public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

//associate the route table with the public subnet
resource "aws_route_table_association" "public" {
  count = length(var.availability_zone)
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

//create a private subnet in the vpc
resource "aws_subnet" "private" {
    vpc_id = aws_vpc.main.id
    count = length(var.availability_zone)
    cidr_block = var.private_subnet_cidr[count.index]
    availability_zone = var.availability_zone[count.index]
    map_public_ip_on_launch = false

    tags = {
      Name = "${var.environment}-private-subnet-${count.index + 1}"
      Environment = var.environment
      "kubernetes.io/role/internal-elb" = "1"
    }
}
//create a elastic ip for the nat gateway
resource "aws_eip" "nat" {
  count = length(var.availability_zone)
  domain = "vpc"

  tags = {
    Name = "${var.environment}-nat-eip-${count.index + 1}"
    Environment = var.environment
  }
}
//create a nat gateway for the private subnet  
resource "aws_nat_gateway" "main" {
  count = length(var.availability_zone)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.environment}-nat-gateway-${count.index + 1}"
    Environment = var.environment
  }
}
//create a route table for the private subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  count = length(var.availability_zone)

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
    }

    depends_on = [aws_nat_gateway.main]

    tags = {
      Name = "${var.environment}-private-route-table-${count.index + 1}"
      Environment = var.environment
    }
}

//create a route table association for the private subnet
resource "aws_route_table_association" "private" {
  count = length(var.availability_zone)
  subnet_id = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
