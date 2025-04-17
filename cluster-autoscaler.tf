resource "aws_iam_role" "cluster_autoscaler"{
	name = "${module.eks.cluster_name}-cluster-autoscaler"

	assume_role_policy = jsonencode({
		Version = "2012-10-17"
		Statement = [
			{
				Effect = "Allow"
				Action = [
					"sts:AssumeRole",
					"sts:TagSession"]
				Principal = {
					Service = "pods.eks.amazonaws.com"
				}
			}
		]
	})
}

resource "aws_iam_policy" "cluster_autoscaler_policy" {
  name = "${module.eks.cluster_name}-cluster-autoscaler"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeScalingActivities",
          "autoscaling:DescribeTags",
          "ec2:DescribeImages",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:GetInstanceTypesFromInstanceRequirements",
          "eks:DescribeNodegroup"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup"
        ]
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
	role       = aws_iam_role.cluster_autoscaler.name
	policy_arn = aws_iam_policy.cluster_autoscaler_policy.arn
}

resource "aws_eks_pod_identity_association" "cluster_autoscaler" {
	cluster_name = module.eks.cluster_name
	namespace    = "kube-system"
	service_account = "cluster-autoscaler"
	role_arn     = aws_iam_role.cluster_autoscaler.arn
}

resource "helm_release" "cluster_autoscaler" {
  name = "autoscaler"

  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  version    = "9.46.6"

  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler"
  }

  set {
    name  = "autoDiscovery.clusterName"
    value = module.eks.cluster_name
  }

  # MUST be updated to match your region 
  set {
    name  = "awsRegion"
    value = "eu-west-1"
  }

  depends_on = [helm_release.metrics-server]
}
