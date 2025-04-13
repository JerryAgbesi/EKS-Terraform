variable "private_subnet_config" {
  default = {
    private_subnet_1 = {
      cidr_block        = "10.0.0.0/20"
      availability_zone = "eu-west-1a"
    }
    private_subnet_2 = {
      cidr_block        = "10.0.16.0/20"
      availability_zone = "eu-west-1b"
    }
  }
}

variable "public_subnet_config" {
  default = {
    public_subnet_1 = {
      cidr_block        = "10.0.32.0/20"
      availability_zone = "eu-west-1c"
    }
    public_subnet_2 = {
      cidr_block        = "10.0.48.0/20"
      availability_zone = "eu-west-1c"
    }
  }
}

variable "aws_profile" {
  description = "AWS profile to use for authentication"
  type        = string
  default     = "lab-user"
}