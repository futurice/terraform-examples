######## IGW ###############
resource "aws_internet_gateway" "main-igw" {
  vpc_id = aws_vpc.msk_vpc.id
  tags = merge(
    local.common-tags,
    map(
      "Name", "MSK-IGW",
      "Description", "Internet Gateway"
    )
  )
}

########### NAT ##############
resource "aws_eip" "nat" {
}

resource "aws_nat_gateway" "main-natgw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet[0].id
  tags = merge(
    local.common-tags,
    map(
      "Name", "MSK-NatGateway",
      "Description", "NAT Gateway"
    )
  )
}

############# Route Tables ##########

resource "aws_route_table" "PublicRouteTable" {
  vpc_id = aws_vpc.msk_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main-igw.id
  }
  tags = merge(
    local.common-tags,
    map(
      "Name", "MSK-Public-Routetable",
      "Description", "Public-Routetable"
    )
  )

}

resource "aws_route_table" "PrivateRouteTable" {
  vpc_id = aws_vpc.msk_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main-natgw.id
  }
  tags = merge(
    local.common-tags,
    map(
      "Name", "MSK-Private-Routetable",
      "Description", "Private-Routetable"
    )
  )
}

#########Route Table Association #############

resource "aws_route_table_association" "route_Publicsubnet" {
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  count          = length(var.public_subnet_cidrs)
  route_table_id = aws_route_table.PublicRouteTable.id
}

resource "aws_route_table_association" "route_Privatesubnet" {
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  count          = length(var.private_subnet_cidrs)
  route_table_id = aws_route_table.PrivateRouteTable.id
}
