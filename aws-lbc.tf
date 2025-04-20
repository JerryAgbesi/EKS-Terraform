data "aws_iam_policy_document" "aws_lbc" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }    
}

resource "aws_iam_role" "aws_lbc_role" {
  name               = "${module.eks.cluster_name}-aws-lbc-role"
  assume_role_policy = data.aws_iam_policy_document.aws_lbc.json
}

resource "aws_iam_policy" "aws_lbc_policy" {
  name = "AWSLoadBalancerController"
  description = "IAM policy for AWS Load Balancer Controller"

  policy = file("./iam/aws-lbc-policy.json")
}

resource "aws_iam_role_policy_attachment" "aws_lbc_role_attachment" {
  role       = aws_iam_role.aws_lbc_role.name
  policy_arn = aws_iam_policy.aws_lbc_policy.arn 
}

resource "aws_eks_pod_identity_association" "aws_lbc" {
  cluster_name = module.eks.cluster_name
  role_arn     = aws_iam_role.aws_lbc_role.arn
  namespace    = "kube-system"
  service_account = "aws-load-balancer-controller"
}

resource "helm_release" "aws_lbc" {
  name = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.12.0"

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
  set {
    name  = "vpcId"
    value = aws_vpc.k8s_main.id
  }

  depends_on = [helm_release.cluster_autoscaler]
}