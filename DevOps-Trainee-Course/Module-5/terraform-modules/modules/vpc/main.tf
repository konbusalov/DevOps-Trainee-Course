locals {
    vpc_id = aws_vpc.vpc.id
    len_public_subnets = length(var.public_subnets)
}

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

    tags = {
        Name = "${var.name_prefix}-public-subnet-${var.azs[count.index]}"
    }
}

resource "aws_route_table" "public" {
    vpc_id = local.vpc_id

    tags = {
        Name = "${var.name_prefix}-rt"
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

output "vpc_id" {
    value = aws_vpc.vpc.id
}

output "subnet_ids" {
    value = aws_subnet.public.*.id
}