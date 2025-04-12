variable "subnet_configs" {
  default = {
    public_subnet_1 = {
      cidr_block        = "10.0.16.0/20"
      availability_zone = "eu-west-1b"
    }
    public_subnet_2 = {
      cidr_block        = "10.0.32.0/20"
      availability_zone = "eu-west-1c"
    }
  }
}