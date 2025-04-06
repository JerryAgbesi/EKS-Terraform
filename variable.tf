variable "subnet_configs" {
  default = {
    subnet_1 = {
      cidr_block        = "10.0.0.0/20"
      availability_zone = "eu-west-1a"
    }
    subnet_2 = {
      cidr_block        = "10.0.16.0/20"
      availability_zone = "eu-west-1b"
    }
    subnet_3 = {
      cidr_block        = "10.0.32.0/20"
      availability_zone = "eu-west-1c"
    }
  }
}