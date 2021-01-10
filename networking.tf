#Create Virtual Private Cloud
resource "aws_vpc" "vpc" {
    cidr_block = var.cidr_vpc
}

#Internet gateway for public access
resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.vpc.id
}

/*
resource "aws_nat_gateway" "ngw_a" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.example.id

  tags = {
    Name = "gw NAT"
  }
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_nat_gateway" "ngw_b" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.example.id

  tags = {
    Name = "gw NAT"
  }
  depends_on = [aws_internet_gateway.gw]
}
*/

#Route table
resource "aws_route" "internet_access" {
    route_table_id         = aws_vpc.vpc.main_route_table_id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.gw.id
}

#Create subnets for each availability zone
resource "aws_subnet" "subnet_public_az_a" {
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = var.cidr_subnet_public_a
    availability_zone       = var.az_a
    map_public_ip_on_launch = true
}
resource "aws_subnet" "subnet_public_az_b" {
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = var.cidr_subnet_public_b
    availability_zone       = var.az_b
    map_public_ip_on_launch = true
}

#Create subnets for each availability zone
resource "aws_subnet" "subnet_private_az_a" {
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = var.cidr_subnet_private_a
    availability_zone       = var.az_a
}
resource "aws_subnet" "subnet_private_az_b" {
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = var.cidr_subnet_private_b
    availability_zone       = var.az_b
}

/*
#Stores list of valid subnets within VPC CIDR block - Public
data "aws_subnet_ids" "dynamic_subnets_list" {
  vpc_id = aws_vpc.vpc.id
}
*/
/*
#Stores list of valid subnets within VPC CIDR block - Private
data "aws_subnet_ids" "dynamic_subnets_list_private" {
  vpc_id = aws_vpc.vpc.id
  tags = {
      Tier = "Private"
  }
}

*/
