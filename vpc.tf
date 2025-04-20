resource "aws_vpc" "k8s_main" {
    cidr_block = "10.0.0.0/16"

    # The VPC must have DNS hostname and DNS resolution support. Otherwise, nodes can’t register to your cluster.(Learnt this the hard way)
    # For more information, see DNS attributes for your VPC in the Amazon VPC User Guide.
    enable_dns_support = true
    enable_dns_hostnames = true
}

resource "aws_internet_gateway" "k8s_igw" {
  vpc_id = aws_vpc.k8s_main.id

  tags = {
    Name      = "k8s-igw"
    Terraform = "true"
  }
}

resource "aws_route_table" "k8s_pub_rtb" {
  vpc_id = aws_vpc.k8s_main.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.k8s_igw.id
    }

    tags = {
      Name      = "k8s-pub-rtb"
      Terraform = "true"
    }
}

resource "aws_route_table" "k8s_priv_rtb" {
  vpc_id = aws_vpc.k8s_main.id

  route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.k8s_nat_gw.id
    }

    tags = {
      Name      = "k8s-priv-rtb"
      Terraform = "true"
    }
}

resource "aws_subnet" "private_subnets" {
  for_each = var.private_subnet_config

  vpc_id                  = aws_vpc.k8s_main.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone

  tags = {
    Name      = each.key
    Terraform = "true"
  }
}

resource "aws_subnet" "public_subnets" {
  for_each = var.public_subnet_config

  vpc_id                  = aws_vpc.k8s_main.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name      = each.key
    Terraform = "true"
    "kubernetes.io/role/elb" = "1"
  }
}


resource "aws_eip" "k8s_nat_eip" {
    domain = "vpc"

    tags = {
      Name     = "k8s-nat-eip"
    }

}

resource "aws_nat_gateway" "k8s_nat_gw" {
  allocation_id = aws_eip.k8s_nat_eip.id
  subnet_id     = values(aws_subnet.public_subnets)[0].id

  tags = {
    Name      = "k8s-nat-gw"
    Terraform = "true"
  }

  depends_on = [ aws_internet_gateway.k8s_igw ]
  
}

resource "aws_route_table_association" "k8s_pub_rtb_assoc" {
  for_each = aws_subnet.public_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.k8s_pub_rtb.id
  
}

resource "aws_route_table_association" "k8s_priv_rtb_assoc" {
  for_each = aws_subnet.private_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.k8s_priv_rtb.id
  
}