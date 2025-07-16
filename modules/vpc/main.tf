data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
    cidr_block           = var.vpc_cidr
    enable_dns_support   = true
    enable_dns_hostnames = true
    
    tags = {
        Name = "${var.name_prefix}-vpc"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "${var.name_prefix}-igw"
    }
}

resource "aws_subnet" "public" {
    count                   = 3
    vpc_id                  = aws_vpc.main.id
    cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
    map_public_ip_on_launch = true
    availability_zone       = data.aws_availability_zones.available.names[count.index]

    tags = {
        Name = "${var.name_prefix}-public-${count.index + 1}"
    }
}

resource "aws_subnet" "private" {
    count             = 3
    vpc_id            = aws_vpc.main.id
    cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 3)
    availability_zone = data.aws_availability_zones.available.names[count.index]

    tags = {
        Name = "${var.name_prefix}-private-${count.index + 1}"
    }
}

resource "aws_eip" "nat" {
  tags = {
    Name = "${var.name_prefix}-eip-nat"
  }
}

resource "aws_nat_gateway" "nat" {
    allocation_id = aws_eip.nat.id
    subnet_id     = aws_subnet.public[0].id

    tags = {
        Name = "${var.name_prefix}-natgw"
    }
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
        Name = "${var.name_prefix}-public-rt"
    }
}

resource "aws_route_table_association" "public" {
    count          = 3
    subnet_id      = aws_subnet.public[count.index].id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block     = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat.id
    }

    tags = {
        Name = "${var.name_prefix}-private-rt"
    }
}

resource "aws_route_table_association" "private" {
    count          = 3
    subnet_id      = aws_subnet.private[count.index].id
    route_table_id = aws_route_table.private.id
}