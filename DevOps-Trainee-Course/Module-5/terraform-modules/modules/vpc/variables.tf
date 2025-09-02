variable "vpc_cidr" {
    default = "10.0.0.0/16"
}   

variable "public_subnets" {
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

