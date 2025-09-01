data "aws_availability_zones" "availability_zones" {}

locals {
    azs = slice(data.aws_availability_zones.availability_zones.names, 0, 3)
}


module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    cidr = "10.0.0.0/16"
    azs = local.azs
    public_subnets = [for k, v in local.azs : cidrsubnet("10.0.0.0/16", 8, k + 4)]
}