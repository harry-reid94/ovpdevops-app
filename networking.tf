#VPC
resource "aws_vpc" "vpc" {
    cidr_block = var.cidr_vpc
}

#Internet gateway
resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.vpc.id
}

# #NAT gateway
# resource "aws_nat_gateway" "ngw_a" {
#   allocation_id = aws_eip.ngw_eip_a.id
#   subnet_id     = aws_subnet.subnet_public_az_a.id
#   depends_on = [aws_internet_gateway.gw]
# }
# resource "aws_eip" "ngw_eip_a" {
#   vpc = true
# }

#Route table
resource "aws_route" "internet_access" {
    route_table_id         = aws_route_table.internet_access.id 
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.gw.id
}

# resource "aws_route" "ngw_a" {
#   route_table_id = aws_route_table.ngw_a.id
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id = aws_nat_gateway.ngw_a.id
# }


#Create subnets for each availability zone - Public
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

# #Create subnets for each availability zone - Private
# resource "aws_subnet" "subnet_private_az_a" {
#     vpc_id                  = aws_vpc.vpc.id
#     cidr_block              = var.cidr_subnet_private_a
#     availability_zone       = var.az_a
# }
# resource "aws_subnet" "subnet_private_az_b" {
#     vpc_id                  = aws_vpc.vpc.id
#     cidr_block              = var.cidr_subnet_private_b
#     availability_zone       = var.az_b
# }

#Route table so public-a and public-b subnet can be assigned to this route table
resource "aws_route_table" "internet_access" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "ovpdevops-public-routetable"
  }
  depends_on = [aws_vpc.vpc]
}


# #Route table NGW
# resource "aws_route_table" "ngw_a" {
#   vpc_id = aws_vpc.vpc.id
#   tags = {
#     Name        = "ovpdevops-public-routetable"
#   }
#   depends_on = [aws_vpc.vpc]
# }


resource "aws_route_table_association" "association_a" {
  subnet_id      = aws_subnet.subnet_public_az_a.id
  route_table_id = aws_route_table.internet_access.id
  
}
resource "aws_route_table_association" "association_b" {
  subnet_id      = aws_subnet.subnet_public_az_b.id
  route_table_id = aws_route_table.internet_access.id
}


# resource "aws_route_table_association" "association_private_a" {
#   subnet_id      = aws_subnet.subnet_private_az_a.id
#   route_table_id = aws_route_table.ngw_a.id
# }
