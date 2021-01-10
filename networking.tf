#Create Virtual Private Cloud
resource "aws_vpc" "vpc" {
    cidr_block = var.cidr_vpc
}

#Internet gateway for public access
resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.vpc.id
}

#Route table
resource "aws_route" "internet_access" {
    route_table_id         = aws_vpc.vpc.main_route_table_id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.gw.id
}

#Create subnets for each availability zone
resource "aws_subnet" "subnet_az_a" {
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = var.cidr_subnet_a
    availability_zone       = var.az_a
    map_public_ip_on_launch = true
}
resource "aws_subnet" "subnet_az_b" {
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = var.cidr_subnet_b
    availability_zone       = var.az_b
    map_public_ip_on_launch = true
}

#Create subnets for each availability zone (Prometheus)
resource "aws_subnet" "subnet_prom_az_a" {
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = var.cidr_subnet_prom_a
    availability_zone       = var.az_a
    map_public_ip_on_launch = true
}
resource "aws_subnet" "subnet_prom_az_b" {
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = var.cidr_subnet_prom_b
    availability_zone       = var.az_b
    map_public_ip_on_launch = true
}

#Stores list of valid subnets within VPC CIDR block
data "aws_subnet_ids" "dynamic_subnets_list" {
  vpc_id = aws_vpc.vpc.id
}
