resource "aws_vpc" "k8s_main" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
}

resource "aws_internet_gateway" "k8s_igw" {
  vpc_id = aws_vpc.k8s_main.id

  tags = {
    Name      = "k8s-igw"
    Terraform = "true"
  }
}

resource "aws_route_table" "k8s_rtb" {
  vpc_id = aws_vpc.k8s_main.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.k8s_igw.id
    }

  route {
      cidr_block = "10.0.0.0/16"
      gateway_id = "local"
    }
}

resource "aws_subnet" "subnets" {
  for_each = var.subnet_configs

  vpc_id                  = aws_vpc.k8s_main.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name      = each.key
    Terraform = "true"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "kubestronaut-eks"
  cluster_version = "1.32"

  cluster_endpoint_public_access = true

  vpc_id                   = aws_vpc.k8s_main.id
  subnet_ids               = [for subnet in aws_subnet.subnets : subnet.id]
  control_plane_subnet_ids = [for subnet in aws_subnet.subnets : subnet.id]

  eks_managed_node_groups = {
    green = {
      min_size       = 1
      max_size       = 1
      desired_size   = 1
      capacity_type = "SPOT"
      instance_types = ["t3.small"]
    }
  }
}


