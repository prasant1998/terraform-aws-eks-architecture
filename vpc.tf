#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

resource "aws_vpc" "testing" {
  cidr_block = "10.0.0.0/16"

  tags = tomap({
    "Name"                                      = "terraform-eks-testing-node",
    "kubernetes.io/cluster/${var.cluster-name}" = "shared",
  })
}

resource "aws_subnet" "testing" {
  count = 2

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.testing.id

  tags = tomap({
    "Name"                                      = "terraform-eks-testing-node",
    "kubernetes.io/cluster/${var.cluster-name}" = "shared",
  })
}

resource "aws_internet_gateway" "testing" {
  vpc_id = aws_vpc.testing.id

  tags = {
    Name = "terraform-eks-testing"
  }
}

resource "aws_route_table" "testing" {
  vpc_id = aws_vpc.testing.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.testing.id
  }
}

resource "aws_route_table_association" "testing" {
  count = 2

  subnet_id      = aws_subnet.testing.*.id[count.index]
  route_table_id = aws_route_table.testing.id
}
