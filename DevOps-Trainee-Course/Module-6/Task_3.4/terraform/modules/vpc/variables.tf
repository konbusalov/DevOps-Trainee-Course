variable "vpc_cidr" {
    default = "10.0.0.0/16"
}   

variable "public_subnets" {
    type = list(string)
    default = []
}

variable "private_subnets" {
    type = list(string)
    default = [] 
}

variable "name_prefix" {
    default = "terraform-course-vpc"
}

variable "azs" {
    type = list(string)
    default = []
}

variable "enable_nat_gateway" {
    type = bool
}

variable "public_subnet_tags" {
    type = map(string)
    default =  {}
}

variable "private_subnet_tags" {
    type = map(string)
    default =  {}
}

