locals {
    vpc_id = aws_vpc.vpc.id
    len_public_subnets = length(var.public_subnets)
    len_private_subnets = length(var.private_subnets)
}

#----------VPC------------

resource "aws_vpc" "vpc" {
    cidr_block = "${var.vpc_cidr}"

    tags = {
        Name = "${var.name_prefix}-vpc"
    }
}

resource "aws_subnet" "public" {
    count = local.len_public_subnets

    vpc_id = local.vpc_id
    cidr_block = element(var.public_subnets, count.index)
    availability_zone = var.azs[count.index]

    tags = merge(
      {
        Name = "${var.name_prefix}-public-subnet-${var.azs[count.index]}"
      },
      var.public_subnet_tags
    )
}

resource "aws_subnet" "private" {
    count = local.len_private_subnets

    vpc_id = local.vpc_id
    cidr_block = element(var.private_subnets, count.index)
    availability_zone = var.azs[count.index]

    tags = merge(
      {
        Name = "${var.name_prefix}-private-subnet-${var.azs[count.index]}"
      },
      var.private_subnet_tags
    )
}

#------PUBLIC ROUTING----------

resource "aws_route_table" "public" {
    vpc_id = local.vpc_id

    tags = {
        Name = "${var.name_prefix}-public-rt"
    }
}

resource "aws_route_table_association" "public" {
    count = local.len_public_subnets

    subnet_id = aws_subnet.public[count.index].id
    route_table_id = aws_route_table.public.id
}

resource "aws_route" "public_internet_gateway" {
    route_table_id = aws_route_table.public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
}

resource "aws_internet_gateway" "igw" {
    vpc_id = local.vpc_id

    tags  = {
        Name = "${var.name_prefix}-igw"    
    }
}

#--------PRIVATE ROUTING---------

resource "aws_eip" "nat" {
    count  = var.enable_nat_gateway ? 1 : 0
    domain = "vpc"

    tags = {
        Name = "${var.name_prefix}-nat-eip-${var.azs[0]}"
    }
}   

resource "aws_nat_gateway" "nat" {
    count  = var.enable_nat_gateway ? 1 : 0
    allocation_id = aws_eip.nat[count.index].id
    subnet_id = aws_subnet.public[0].id

    tags = {
        Name = "${var.name_prefix}-nat-gw-${var.azs[0]}"
    }

    depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "private" {  
    vpc_id = local.vpc_id

    tags = {
        Name = "${var.name_prefix}-private-rt"
    }
}

resource "aws_route" "private_nat_gateway" {
    count  = var.enable_nat_gateway ? 1 : 0

    route_table_id         = aws_route_table.private.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id         = aws_nat_gateway.nat[count.index].id
}

resource "aws_route_table_association" "private" {
    count = local.len_private_subnets

    subnet_id = aws_subnet.private[count.index].id
    route_table_id = aws_route_table.private.id
}

#--------OUTPUTS----------

output "vpc_id" {
    value = aws_vpc.vpc.id
}

output "public_subnet_ids" {
    value = aws_subnet.public.*.id
}

output "private_subnet_ids" {
    value = aws_subnet.private.*.id
}