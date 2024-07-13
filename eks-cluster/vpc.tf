#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

resource "aws_vpc" "eks-vpc" {
  cidr_block = "${var.vpc_cidr_block}"

  tags = tomap({
    "Name"                                      = "${var.cluster_name}-tag",
    "kubernetes.io/cluster/${var.cluster_name}" = "shared",
  })
}

resource "aws_subnet" "eks-subnet" {
  count = "${var.no_of_public_subnet}"

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = cidrsubnet(aws_vpc.eks-vpc.cidr_block, 8, count.index)
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.eks-vpc.id

  tags = tomap({
    "Name"                                      = "${var.cluster_name}-tag",
    "kubernetes.io/cluster/${var.cluster_name}" = "shared",
  })
}

resource "aws_internet_gateway" "eks-gw" {
  vpc_id = aws_vpc.eks-vpc.id

  tags = {
    Name = "${var.cluster_name}-tag"
  }
}

resource "aws_route_table" "eks-art" {
  vpc_id = aws_vpc.eks-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks-gw.id
  }
}

resource "aws_route_table_association" "eks-arta" {
  count = "${var.no_of_public_subnet}"

  subnet_id      = aws_subnet.eks-subnet[count.index].id
  route_table_id = aws_route_table.eks-art.id
}