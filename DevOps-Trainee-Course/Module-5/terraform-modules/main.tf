data "aws_availability_zones" "available_azs" {}

locals {
    azs = slice(data.aws_availability_zones.available_azs.names, 0, 3)
}

module "vpc" {
    source = "./modules/vpc"
    name_prefix = "trainee_project"
    azs = local.azs
    vpc_cidr = "10.0.0.0/16"
    public_subnets = [for k, v in local.azs : cidrsubnet("10.0.0.0/16", 8, k + 4)]
}
