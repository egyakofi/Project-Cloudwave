
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs    = slice(data.aws_availability_zones.available.names, 0, 6)
  vpc_id = aws_vpc.CloudWave-Project.id
  required_tags = {
    "ChargeCode" = "04NSOC.SUPP.0000.NSV" ### tag
  }
}

resource "aws_vpc" "CloudWave-Project" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_internet_gateway" "cloudwave-igw" {
  vpc_id = aws_vpc.CloudWave-Project.id
}

resource "aws_subnet" "cloudwave-public" {
  count             = length(local.azs)
  vpc_id            = local.vpc_id
  cidr_block        = var.public_subnet_cidr[count.index]
  availability_zone = local.azs[count.index]
  depends_on = [aws_vpc.CloudWave-Project]
}

resource "aws_subnet" "cloudwave-private" {
  count             = length(local.azs)
  vpc_id            = local.vpc_id
  cidr_block        = var.private_subnet_cidr[count.index]
  availability_zone = local.azs[count.index]
  depends_on = [aws_vpc.CloudWave-Project]
}
##################################################
resource "aws_route_table" "cloudwave-public-rt" {
  vpc_id = local.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cloudwave-igw.id
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.cloudwave-public)
  subnet_id      = aws_subnet.cloudwave-public[count.index].id
  route_table_id = aws_route_table.cloudwave-public-rt.id
}

resource "aws_route_table" "cloudwave-private-rt" {
  vpc_id = local.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.cloudwave-ngw.id
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.cloudwave-private)
  subnet_id      = aws_subnet.cloudwave-private[count.index].id
  route_table_id = aws_route_table.cloudwave-private-rt.id
}

resource "aws_nat_gateway" "cloudwave-ngw" {

  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.cloudwave-public[0].id
  depends_on    = [aws_internet_gateway.cloudwave-igw]
}

resource "aws_eip" "eip" {
  depends_on = [aws_internet_gateway.cloudwave-igw]
  vpc        = true
}

# resource "aws_subnet" "cloudwave-public" {
#   vpc_id                  = aws_vpc.CloudWave-Project.id
#   cidr_block              = var.vpc_cidr_block
#   availability_zone       = ["us-east-1b", "us-east-1a"]
#   map_public_ip_on_launch = true
#   depends_on = [aws_vpc.CloudWave-Project]
   
#   tags = {
#     Name = "cloudwave-public"
#   }
# }

# resource "aws_subnet" "cloudwave-private" {
#   vpc_id                  = aws_vpc.CloudWave-Project.id
#   cidr_block              = var.vpc_cidr_block
#   availability_zone       = ["us-east-1b", "us-east-1a"]
#   map_public_ip_on_launch = true
#   depends_on = [aws_vpc.CloudWave-Project]
   
#   tags = {
#     Name = "cloudwave-public"
#   }
# }
