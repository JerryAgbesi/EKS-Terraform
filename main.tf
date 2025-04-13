module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "practice-eks"
  cluster_version = "1.32"

  cluster_endpoint_public_access = true

  vpc_id                   = aws_vpc.k8s_main.id
  subnet_ids               = [for subnet in aws_subnet.private_subnets : subnet.id]

  eks_managed_node_groups = {
    green = {
      min_size       = 1
      max_size       = 2
      desired_size   = 1
      capacity_type = "SPOT"
      instance_types = ["t3.small"]
    }
  }
}


